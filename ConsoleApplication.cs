public class ConsoleApplication {
    private readonly ICardReader cardReader;
    public ConsoleApplication(ICardReader cardReader) { this.cardReader = cardReader; }
    public void main(string[] args) { Console.WriteLine(cardReader.ReadInput()); }
}
