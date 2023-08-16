/* eslint-disable @typescript-eslint/no-var-requires */
const path = require('path');
const skeleton = require('@skeletonlabs/skeleton/tailwind/skeleton.cjs');

/** @type {import('tailwindcss').Config}*/
const config = {
	darkMode: 'media',
	content: [
		'./src/**/*.{html,js,svelte,ts}',
		path.join(require.resolve('@skeletonlabs/skeleton'), '../**/*.{html,js,svelte,ts}')
	],
	theme: {
		extend: {}
	},

	plugins: [require('@tailwindcss/forms'), ...skeleton()]
};

module.exports = config;
