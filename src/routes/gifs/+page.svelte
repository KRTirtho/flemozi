<script lang="ts">
	import { giphy } from '$lib/services';
	import type { IGif } from '@giphy/js-types';
	import { createInfiniteQuery } from '@tanstack/svelte-query';
	import SvelteIntersectionObserver from 'svelte-intersection-observer';

	const trendingQuery = createInfiniteQuery<IGif[], IGif[]>(
		['gifs'],
		async ({ pageParam = 0 }) => {
			const { data } = await giphy.trending({
				offset: pageParam * 20,
				limit: 20,
				type: 'gifs'
			});
			return data;
		},
		{
			getNextPageParam: (lastPage, allPages) => (lastPage.length < 20 ? false : allPages.length)
		}
	);

	const searchQuery = createInfiniteQuery<IGif[], IGif[]>(
		['search-gifs'],
		async ({ pageParam = 0 }) => {
			console.log('searchValue:', searchValue);
			const { data } = await giphy.search(searchValue, {
				offset: pageParam * 10,
				limit: 10,
				type: 'gifs'
			});
			return data;
		},
		{
			enabled: false,
			getNextPageParam: (lastPage, allPages) => (lastPage.length < 10 ? false : allPages.length)
		}
	);

	let searchInput: HTMLInputElement;
	let gifDiv: HTMLDivElement;
	let gifDivs: Array<HTMLDivElement>;
	let numberOfCols = 0;

	let searchValue: string = '';
	let element: HTMLElement;
	let intersecting: boolean;

	let gifs: IGif[] = [];

	let timer: number;

	let query: typeof trendingQuery | typeof searchQuery;

	$: {
		query = searchValue.length > 2 ? searchQuery : trendingQuery;
		gifs = $query.data?.pages.flatMap((page) => page) ?? [];

		if (intersecting && !$query.isFetchingNextPage && $query.hasNextPage) {
			$query.fetchNextPage();
		}

		if (gifDiv) {
			gifDivs = Array.from(gifDiv.querySelectorAll('div'));

			const computedStyle = window.getComputedStyle(gifDiv);
			const gridTemplateColumns = computedStyle
				.getPropertyValue('grid-template-columns')
				.split(' ').length;
			numberOfCols = gridTemplateColumns;
		}
	}

	function onInput(e: Event & { currentTarget: EventTarget & HTMLInputElement }) {
		const target = e.target as HTMLInputElement;
		if (!target.value) {
			searchValue = '';
			clearTimeout(timer);
			return;
		}
		timer = setTimeout(() => {
			clearTimeout(timer);
			cancelAnimationFrame(timer);
			if (!target?.value || searchValue === target?.value || target?.value.length < 3) {
				return;
			}
			searchValue = target.value;
			$searchQuery.remove();
			$searchQuery.refetch();
		}, 2000);
	}

	function onGifKey(e: KeyboardEvent, gif: IGif) {
		// any alphanumeric key
		if (e.key.match(/^[a-z0-9]$/i)) {
			searchInput.focus();
			searchInput.value = e.key;
			element.scrollTop = 0;
		}

		const target = e.target as HTMLDivElement;

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
				const isFirstRow = gifDivs.indexOf(target) < numberOfCols;
				if (isFirstRow) {
					searchInput.focus();
				} else {
					const index = gifDivs.indexOf(target);
					const prevRow = index - numberOfCols;
					const prevButton = gifDivs[prevRow];
					prevButton?.focus();
				}
				break;
			}
			case 'ArrowDown': {
				const index = gifDivs.indexOf(target);
				const nextRow = index + numberOfCols;
				const nextButton = gifDivs[nextRow];
				nextButton?.focus();
				break;
			}
		}
	}

	function onInputKeyUp(e: KeyboardEvent) {
		switch (e.key) {
			case 'ArrowDown': {
				const el = gifDiv!.querySelector('div') as HTMLButtonElement | null;
				el?.focus();
				break;
			}
			case 'Enter': {
				e.preventDefault();
				gifDivs[0]?.focus();
				break;
			}
		}
	}
</script>

<div class="space-y-2">
	<input
		autofocus
		class="input"
		type="search"
		placeholder="Search..."
		on:input={onInput}
		on:keyup={onInputKeyUp}
		bind:this={searchInput}
	/>

	<div class="grid-container" bind:this={gifDiv}>
		{#each gifs as gif}
			<div
				tabindex="0"
				on:click={() => {
					console.log('clicked');
				}}
				on:keyup|preventDefault={(e) => onGifKey(e, gif)}
				role="button"
				class="focus:outline-none focus:ring-4 focus:ring-offset-4 focus:ring-rose-500 focus:brightness-75 hover:brightness-75 active:brightness-50 focus:scale-95 active:scale-95 transition-all cursor-pointer rounded-lg"
			>
				<img
					src={gif.images.fixed_width_downsampled.url
						.replace(/media\d\.giphy\.com/, 'i.giphy.com')
						.split('?')[0]}
					alt={gif.title}
					class="h-auto w-full rounded-lg"
				/>
			</div>
		{/each}
		{#if !$query.isFetchingNextPage || $query.hasNextPage !== false}
			<SvelteIntersectionObserver {element} bind:intersecting>
				<div bind:this={element} class="w-full col-span-3 grid-container">
					<div class="h-52 w-full placeholder animate-pulse rounded-lg" />
					<div class="h-52 w-full placeholder animate-pulse rounded-lg" />
					<div class="h-52 w-full placeholder animate-pulse rounded-lg" />
				</div>
			</SvelteIntersectionObserver>
		{/if}
	</div>
</div>

<style lang="postcss">
	.grid-container {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
		align-items: center;
		gap: 10px;
	}
</style>
