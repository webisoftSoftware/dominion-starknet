export class ChainException extends Error {
  constructor(message: string, previous?: Error) {
    super(message);
    this.name = 'ChainException';
    this.cause = previous;
  }
}
