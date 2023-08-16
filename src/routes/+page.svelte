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
</script>

<div class="flex flex-col gap-4">
	<input class="input" type="search" placeholder="Search..." />
	{#each categorizedEmoji as [category, emojis]}
		<section>
			<h5 class="text-lg font-medium text-gray-600">
				{category}
			</h5>
			<div class="flex flex-wrap gap-1">
				{#each emojis as emoji}
					<button
						class="text-3xl btn-icon select-none"
						on:click={() => {
							writeText(emoji.emoji);
							toastStore.clear();
							toastStore.trigger({
								message: `Copied ${emoji.emoji} (${emoji.description}) to clipboard`
							});
              appWindow.hide();
						}}
					>
						{emoji.emoji}
					</button>
				{/each}
			</div>
		</section>
	{/each}
</div>
