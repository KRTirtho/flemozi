<script lang="ts">
	import { popup, toastStore, type PopupSettings } from '@skeletonlabs/skeleton';
	import { writeText } from '@tauri-apps/api/clipboard';
	import type { UnlistenFn } from '@tauri-apps/api/event';
	import { appWindow } from '@tauri-apps/api/window';
	import { onMount } from 'svelte';

	export let data: [string, any[]][];
	export let display: 'grid' | 'flex' = 'grid';
	export let compare: (data: any, search: string) => boolean;
	export let getTooltip: ((data: any) => string) | undefined;
	export let getDataString: (data: any) => string;

	let searchInput: HTMLInputElement;
	let searchValue: string;
	let emojiDiv: HTMLDivElement | null = null;

	let numberOfCols = 0;
	let buttons: Array<HTMLButtonElement>;

	let filteredData: typeof data = [];

	$: {
		if (emojiDiv) {
			const grid = emojiDiv.querySelector('.grid');
			if (grid) {
				const computedStyle = window.getComputedStyle(grid);
				const gridTemplateColumns = computedStyle
					.getPropertyValue('grid-template-columns')
					.split(' ').length;
				numberOfCols = gridTemplateColumns;

				buttons = Array.from(emojiDiv!.querySelectorAll('button'));
			}
		}
		filteredData = searchValue
			? data
					.map(([category, emojis]) => {
						return [category, emojis.filter((emoji) => compare(emoji, searchValue))] as [
							string,
							any[]
						];
					})
					.filter(([_, emojis]) => emojis.length > 0)
			: data;
	}

	onMount(() => {
		const subscriptions: Array<UnlistenFn> = [];

		(async () => {
			subscriptions.push(
				await appWindow.listen('tauri://blur', () => {
					searchValue = '';
				}),
				await appWindow.listen('tauri://focus', () => {
					searchInput.focus();
				})
			);
		})();

		function listener() {
			searchInput.focus();
		}
		window.addEventListener('focus', listener);

		return () => {
			window.removeEventListener('focus', listener);
			for (const unsubscribe of subscriptions) {
				unsubscribe();
			}
		};
	});

	function onEmojiKey(e: KeyboardEvent, data: any) {
		const target = e.target as HTMLButtonElement;

		if (e.key === 'Enter') {
			onClickCopyEmoji(data);
			if (!e.ctrlKey) {
				appWindow.hide();
			}
		}
		switch (e.key) {
			case 'ArrowRight': {
				(target.nextSibling as HTMLButtonElement | null)?.focus();
				break;
			}
			case 'ArrowLeft': {
				(target.previousSibling as HTMLButtonElement | null)?.focus();
				break;
			}
			case 'ArrowUp': {
				const isFirstRow = buttons.indexOf(target) < numberOfCols;
				if (isFirstRow) {
					searchInput.focus();
				} else {
					const index = buttons.indexOf(target);
					const prevRow = index - numberOfCols;
					const prevButton = buttons[prevRow];
					prevButton?.focus();
				}
				break;
			}
			case 'ArrowDown': {
				const index = buttons.indexOf(target);
				const nextRow = index + numberOfCols;
				const nextButton = buttons[nextRow];
				nextButton?.focus();
				break;
			}
		}

		// any alphanumeric key
		if (e.key.match(/^[a-z0-9]$/i)) {
			searchInput.focus();
			searchInput.value = e.key;
			emojiDiv!.scrollTop = 0;
		}
	}

	function onInputKeyUp(e: KeyboardEvent) {
		switch (e.key) {
			case 'ArrowDown': {
				const el = emojiDiv!.querySelector('button') as HTMLButtonElement | null;
				el?.focus();
				break;
			}
			case 'Enter': {
				e.preventDefault();
				buttons[0]?.focus();
				break;
			}
		}
	}

	function onClickCopyEmoji(data: any) {
		const text = getDataString(data);
		writeText(text);
		toastStore.clear();
		toastStore.trigger({
			message: `Copied ${text} to clipboard`
		});
	}

	const popupSettings: PopupSettings = {
		event: 'focus-blur',
		target: 'popupFocusBlur',
		placement: 'bottom'
	};
</script>

<div class="flex flex-col h-full">
	<input
		autofocus
		bind:this={searchInput}
		class="input"
		type="search"
		placeholder="Search..."
		bind:value={searchValue}
		on:keyup={onInputKeyUp}
	/>
	<div class="mt-2 h-full overflow-auto space-y-2 scroll-smooth" bind:this={emojiDiv}>
		{#each filteredData as [category, data]}
			<section>
				<h5 class="text-lg font-medium text-gray-600">
					{category}
				</h5>
				<div
					class={display === 'grid' ? 'grid' : 'flex flex-wrap gap-2'}
					style="grid-template-columns: repeat(auto-fill, minmax(43px, 1fr));"
				>
					{#each data as child}
						<button
							class={`${
								display === 'grid' ? 'text-3xl' : ''
							} btn-icon select-none focus:ring focus:ring-red-500 outline-none`}
							on:click={(e) => {
								onClickCopyEmoji(child);

								if (!e.ctrlKey) {
									appWindow.hide();
								}
							}}
							on:keyup|preventDefault={(e) => onEmojiKey(e, child)}
							use:popup={{
								...popupSettings,
								target: `tooltip-${getDataString(child)}`
							}}
						>
							{#if getTooltip}
								<div
									class="text-sm card p-2 variant-filled"
									data-popup={`tooltip-${getDataString(child)}`}
								>
									<p>{getTooltip(child)}</p>
									<div class="arrow variant-filled" />
								</div>
							{/if}
							{getDataString(child)}
						</button>
					{/each}
				</div>
			</section>
		{/each}
	</div>
</div>
