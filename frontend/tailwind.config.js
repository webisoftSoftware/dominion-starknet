const { createGlobPatternsForDependencies } = require('@nx/react/tailwind');
const { join } = require('path');

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    join(__dirname, '{src,pages,components,app}/**/*!(*.stories|*.spec).{ts,tsx,html}'),
    ...createGlobPatternsForDependencies(__dirname),
  ],
  theme: {
    fontFamily: {
      sans: ['"Inter Variable"', 'sans-serif'],
    },
    extend: {
      colors: {
        primary: '#0a1a2a',
        secondary: '#141d2d',
        tertiary: '#1e2b42',
        accent: '#18BDE9',
        special: '#343F54', // used for bg blur & check button
        text: {
          primary: '#F9FAFB',
          secondary: '#D0D5DD',
          tertiary: '#98A2B3',
          disabled: '#6B7280',
        },
        error: '#D92D20',
      },
      boxShadow: {
        'inner-skeu': '0px -2px 1px 0px #0C111D77 inset, 0px 0px 0px 2px #FFFFFF20 inset',
      },
      screens: {
        'sm-mobile': '320px',
        'md-mobile': '375px',
        'lg-mobile': '550px',
        'h-xs': { 'raw': '(min-height: 670px)' },
      }
    },
  },
  plugins: [],
};
