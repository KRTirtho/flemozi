<script lang="ts">
	import { emoticons } from '$lib';
	import NavigatableContiner from '$lib/components/NavigatableContiner.svelte';

	const emoticonEntries = Object.entries(emoticons);

	function emojiCompare(rawEmoticon: any, searchValue: string): boolean {
		const emotiCon = rawEmoticon as string;
		return emoticonEntries.some(([category, emoticons]) => {
			return (
				emoticons.includes(emotiCon) && category.toLowerCase().includes(searchValue.toLowerCase())
			);
		});
	}

	function getEmojiText(rawEmoji: any): string {
		return rawEmoji as string;
	}
</script>

<NavigatableContiner
	data={emoticonEntries}
	compare={emojiCompare}
	getDataString={getEmojiText}
	display="flex"
	getTooltip={undefined}
/>
