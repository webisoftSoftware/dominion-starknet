import React from 'react';

interface ThemeColors {
  tableColor: string;
  innerStroke: string;
  exteriorFill: string;
  exteriorStroke: string;
}

export const themeColors: Record<string, ThemeColors> = {
  neon: {
    // Original SVG colors
    tableColor: '#1ACFFF',
    innerStroke: '#A3ECFF',
    exteriorFill: '#1ACFFF',
    exteriorStroke: '#033344',
  },
  solar: {
    tableColor: '#FFCD34',
    innerStroke: '#FFCD34',
    exteriorFill: '#E7B826',
    exteriorStroke: '#443803',
  },
  violet: {
    tableColor: '#6322E9',
    innerStroke: '#AD83FF',
    exteriorFill: '#6D21FF',
    exteriorStroke: '#1D0344',
  },
  crimson: {
    tableColor: '#FF195B',
    innerStroke: '#FD9DB9',
    exteriorFill: '#E61956',
    exteriorStroke: '#440312',
  },
  synth: {
    tableColor: '#7BD763',
    innerStroke: '#A7E498',
    exteriorFill: '#6FC55C',
    exteriorStroke: '#1F3E19',
  },
  verdant: {
    tableColor: '#58B476',
    innerStroke: '#8CE8AA',
    exteriorFill: '#4A9D67',
    exteriorStroke: '#003411',
  },
  element: {
    tableColor: '#1A7841',
    innerStroke: '#597b67',
    exteriorFill: '#186E3F',
    exteriorStroke: '#021f0f',
  },
  amber: {
    tableColor: '#FF491A',
    innerStroke: '#FBA58F',
    exteriorFill: '#E85832',
    exteriorStroke: '#441403',
  },
};

interface ThemeSVGProps {
  className?: string;
  style?: React.CSSProperties;
  theme: string | null;
}

export function ThemeSVG({ className, style, theme }: ThemeSVGProps) {
  const colors = themeColors[theme ? theme : 'neon'];

  return (
    <svg className={className} style={style} viewBox='0 0 361 766' fill='none' xmlns='http://www.w3.org/2000/svg'>
      {/* Table base */}
      <path
        d='M2.5 585.437L2.50002 180.563C2.50003 82.3812 82.3533 2.49999 180.5 2.49999C278.647 2.5 358.5 82.3801 358.5 180.563L358.5 585.437C358.5 683.62 278.647 763.5 180.5 763.5C82.3533 763.5 2.5 683.62 2.5 585.437Z'
        fill={colors?.exteriorFill}
        fillOpacity='1'
        stroke={colors?.exteriorStroke}
        strokeWidth='5'
      />
      <path
        d='M46 581.661L46 185.339C46 148.384 60.1706 112.942 85.3942 86.8114C110.618 60.6803 144.828 46 180.5 46C216.172 46 250.382 60.6803 275.606 86.8114C300.83 112.942 315 148.384 315 185.339L315 581.661C315 618.616 300.83 654.058 275.606 680.189C250.382 706.32 216.172 721 180.5 721C144.828 721 110.618 706.32 85.3942 680.189C60.1706 654.058 46 618.616 46 581.661Z'
        fill={colors?.tableColor}
        stroke={colors?.innerStroke}
        strokeWidth='0.767139'
        strokeOpacity='0.5'
        strokeMiterlimit='10'
      />
    </svg>
  );
}

export function ThemeSelector({
  onSelectTheme,
  selectedTheme,
}: {
  onSelectTheme: (theme: string) => void;
  selectedTheme: string;
}) {
  return (
    <div className='grid grid-cols-2 gap-2 sm:grid-cols-4 sm:gap-4'>
      {Object.keys(themeColors).map((theme) => (
        <button about={"Select table theme"}
          key={theme}
          onClick={() => onSelectTheme(theme)}
          className={`flex flex-col items-center rounded p-2 ${
            selectedTheme === theme ? 'ring-2 ring-yellow-300' : 'hover:ring-2 hover:ring-yellow-300/50'
          }`}
        >
          <ThemeSVG theme={theme} className='h-12 w-12 sm:h-16 sm:w-16' />
          <span className='text-text-primary bg-secondary mt-1 flex h-full flex-col items-center justify-center text-xs capitalize sm:text-sm'>
            {theme}
          </span>
        </button>
      ))}
    </div>
  );
}
