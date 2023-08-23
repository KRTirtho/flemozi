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
	import { listen, type UnlistenFn } from '@tauri-apps/api/event';
	import * as autoStart from 'tauri-plugin-autostart-api';
	import { computePosition, autoUpdate, offset, shift, flip, arrow } from '@floating-ui/dom';
	import { storePopup } from '@skeletonlabs/skeleton';
	import { QueryClient, QueryClientProvider } from '@tanstack/svelte-query';
	import { browser } from '$app/environment';

	storePopup.set({ computePosition, autoUpdate, offset, shift, flip, arrow });

	onMount(() => {
		let unsubscribe: UnlistenFn | null = null;
		(async () => {
			if (await isRegistered('CmdOrControl+Shift+/')) {
				await unregister('CmdOrControl+Shift+/');
			}
			await register('CmdOrControl+Shift+/', async () => {
				await appWindow.show();
				await appWindow.setAlwaysOnTop(true);
				await appWindow.setFocus();
			});

			unsubscribe = await listen('showWindow', () => {
				console.log('showWindow:');
				appWindow.show();
				appWindow.setAlwaysOnTop(true);
				appWindow.setFocus();
			});

			await autoStart.enable();
		})();

		function listener(e: KeyboardEvent) {
			if (e.key === 'Escape') {
				appWindow.hide();
			}
		}

		document.addEventListener('keyup', listener);
		return () => {
			if (unsubscribe) unsubscribe();
			document.removeEventListener('keyup', listener);
		};
	});

	const queryClient = new QueryClient({
		defaultOptions: {
			queries: {
				enabled: browser
			}
		}
	});
</script>

<Toast padding="p-3" />

<QueryClientProvider client={queryClient}>
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
		<div class="p-2 w-full h-screen overflow-auto scroll-smooth">
			<slot />
		</div>
	</main>
</QueryClientProvider>
