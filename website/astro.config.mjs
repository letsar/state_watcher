import starlight from '@astrojs/starlight';
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
	base: '/state_watcher/',
	logo: {
		light: './src/assets/light-logo.svg',
		dark: './src/assets/dark-logo.svg',
	},
	integrations: [
		starlight({
			title: 'state watcher',
			social: {
				github: 'https://github.com/letsar/state_watcher',
			},
			sidebar: [
				{
					label: 'Introduction',
					autogenerate: { directory: 'introduction' },
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
				},
				{
					label: 'Guid',
					autogenerate: { directory: 'guide' },
				},
				{
					label: 'Tools',
					autogenerate: { directory: 'tools' },
				},
			],
		}),
	],
});
