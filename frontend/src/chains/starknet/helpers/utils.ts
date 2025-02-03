/**
 * Clean up localStorage entries for a table
 * @param {number} tableId - Table ID
 */
export function cleanupLocalStorage(tableId: string) {
    localStorage.removeItem(`decryption_secret_${tableId}`);
    localStorage.removeItem(`decrypted_hand_${tableId}`);
}