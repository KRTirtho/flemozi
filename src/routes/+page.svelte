<script lang="ts">
	import { emojis, type Emoji } from '$lib';
	import NavigatableContiner from '$lib/components/NavigatableContiner.svelte';

	const categorizedEmoji = Object.entries(
		emojis.reduce((acc, emoji) => {
			const category = emoji.category ?? 'other';
			if (!acc[category]) acc[category] = [];
			acc[category].push(emoji);
			return acc;
		}, {} as Record<string, Emoji[]>)
	);

	function emojiCompare(rawEmoji: any, searchValue: string): boolean {
		const emoji = rawEmoji as Emoji;
		return !!(
			emoji.description.toLowerCase().includes(searchValue.toLowerCase()) ||
			emoji.aliases.some((alias) => alias.includes(searchValue)) ||
			emoji.tags?.some((tag) => tag.includes(searchValue))
		);
	}

	function getEmojiText(rawEmoji: any): string {
		const emoji = rawEmoji as Emoji;
		return emoji.emoji;
	}
</script>

<NavigatableContiner data={categorizedEmoji} compare={emojiCompare} getDataString={getEmojiText} />
