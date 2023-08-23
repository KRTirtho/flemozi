import { GiphyFetch } from '@giphy/js-fetch-api';
import { PUBLIC_GIPHY_API_KEY } from '$env/static/public';

export const giphy = new GiphyFetch(PUBLIC_GIPHY_API_KEY);
