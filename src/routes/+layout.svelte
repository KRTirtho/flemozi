<script lang="ts">
	import '@skeletonlabs/skeleton/themes/theme-skeleton.css';
	import '@skeletonlabs/skeleton/styles/skeleton.css';
	import '../app.css';
	import { appWindow } from '@tauri-apps/api/window';
	import { register, isRegistered, unregister } from '@tauri-apps/api/globalShortcut';
	import { AppRail, AppRailAnchor, Toast } from '@skeletonlabs/skeleton';
	import Icon from '@iconify/svelte';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { StateFlags, saveWindowState } from 'tauri-plugin-window-state-api';

	onMount(() => {
		(async () => {
			if (await isRegistered('CmdOrControl+Shift+/')) {
				await unregister('CmdOrControl+Shift+/');
			}
			await register('CmdOrControl+Shift+/', async () => {
				await appWindow.show();
				await appWindow.setAlwaysOnTop(true);
				await appWindow.setFocus();
			});
		})();
	});
</script>

<Toast padding="p-3" />

<main class="flex items-start">
	<div
		class="h-screen"
		on:dragstart={async (event) => {
			event.dataTransfer?.setDragImage(new Image(), -9999, -9999);
			await appWindow.startDragging();
			return false;
		}}
		draggable={true}
		role="navigation"
	>
		<button
			class="btn-icon"
			on:click={async () => {
				await saveWindowState(StateFlags.ALL);
				await appWindow.hide();
			}}
		>
			<Icon icon="pepicons-pop:times-circle" />
		</button>
		<AppRail height="h-[87vh]" width="w-10" border="rounded-r-lg">
			<AppRailAnchor href="/" selected={$page.url.pathname === '/'}>
				<Icon icon="bi:emoji-laughing" slot="lead" />
			</AppRailAnchor>
			<AppRailAnchor href="/emoticons" selected={$page.url.pathname === '/emoticons'}>
				<span>:-&rpar;</span>
			</AppRailAnchor>
			<AppRailAnchor href="/gifs" selected={$page.url.pathname === '/gifs'}>
				<Icon icon="bi:filetype-gif" slot="lead" />
			</AppRailAnchor>
		</AppRail>
	</div>
	<div class="p-2 w-full h-screen overflow-auto">
		<slot />
	</div>
</main>
