<script lang="ts">
	import { emojis, type Emoji } from '$lib';
	import { toastStore } from '@skeletonlabs/skeleton';
	import { writeText } from '@tauri-apps/api/clipboard';
	import { appWindow } from '@tauri-apps/api/window';

	const categorizedEmoji = Object.entries(
		emojis.reduce((acc, emoji) => {
			const category = emoji.category ?? 'other';
			if (!acc[category]) acc[category] = [];
			acc[category].push(emoji);
			return acc;
		}, {} as Record<string, Emoji[]>)
	);

	let searchInput: HTMLInputElement;
	let searchValue: string;
	let emojiDiv: HTMLDivElement | null = null;

	let numberOfCols = 0;
	let emojiButtons: Array<HTMLButtonElement>;

	let filteredCategoryEmojis: typeof categorizedEmoji = [];

	$: {
		if (emojiDiv) {
			const grid = emojiDiv.querySelector('.grid');
			if (grid) {
				const computedStyle = window.getComputedStyle(grid);
				const gridTemplateColumns = computedStyle
					.getPropertyValue('grid-template-columns')
					.split(' ').length;
				numberOfCols = gridTemplateColumns;

				emojiButtons = Array.from(emojiDiv!.querySelectorAll('button'));
			}
		}
		filteredCategoryEmojis = searchValue
			? categorizedEmoji
					.map(([category, emojis]) => {
						return [
							category,
							emojis.filter(
								(emoji) =>
									emoji.description.toLowerCase().includes(searchValue.toLowerCase()) ||
									emoji.aliases.some((alias) => alias.includes(searchValue)) ||
									emoji.tags?.some((tag) => tag.includes(searchValue))
							)
						] as [string, Emoji[]];
					})
					.filter(([_, emojis]) => emojis.length > 0)
			: categorizedEmoji;
	}

	function onEmojiKey(e: KeyboardEvent) {
		const target = e.target as HTMLButtonElement;

		if (e.key === 'Enter') {
			target.click();
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
				const isFirstRow = emojiButtons.indexOf(target) < numberOfCols;
				if (isFirstRow) {
					searchInput.focus();
				} else {
					const index = emojiButtons.indexOf(target);
					const prevRow = index - numberOfCols;
					const prevButton = emojiButtons[prevRow];
					prevButton?.focus();
				}
				break;
			}
			case 'ArrowDown': {
				const index = emojiButtons.indexOf(target);
				const nextRow = index + numberOfCols;
				const nextButton = emojiButtons[nextRow];
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

	function onInputKeyDown(e: KeyboardEvent) {
		if (e.key === 'ArrowDown') {
			const el = emojiDiv!.querySelector('button') as HTMLButtonElement | null;
			el?.focus();
		}
	}
</script>

<div class="flex flex-col h-full">
	<input
		bind:this={searchInput}
		class="input"
		type="search"
		placeholder="Search..."
		bind:value={searchValue}
		on:keydown={onInputKeyDown}
	/>
	<div class="mt-2 h-full overflow-auto space-y-2 scroll-smooth" bind:this={emojiDiv}>
		{#each filteredCategoryEmojis as [category, emojis]}
			<section>
				<h5 class="text-lg font-medium text-gray-600">
					{category}
				</h5>
				<div class="grid" style="grid-template-columns: repeat(auto-fill, minmax(43px, 1fr));">
					{#each emojis as emoji}
						<button
							class="text-3xl btn-icon select-none focus:ring focus:ring-tertiary-100-800-token outline-none"
							on:click={() => {
								writeText(emoji.emoji);
								toastStore.clear();
								toastStore.trigger({
									message: `Copied ${emoji.emoji} (${emoji.description}) to clipboard`
								});
								appWindow.hide();
							}}
							on:keyup|preventDefault={onEmojiKey}
						>
							{emoji.emoji}
						</button>
					{/each}
				</div>
			</section>
		{/each}
	</div>
</div>
