export const formatChips = (chips: number) => {
  return Intl.NumberFormat('en-US', {
    notation: chips > 99999 ? 'compact' : 'standard', // At 6 digits, switch to compact notation
    maximumFractionDigits: 1,
  }).format(chips);
};
