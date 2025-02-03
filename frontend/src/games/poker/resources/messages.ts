export type ChatMessage = {
  senderId: string | null;
  senderAvatar: string | null;
  text: string;

  roomId: number;
  roundId: number;
};
