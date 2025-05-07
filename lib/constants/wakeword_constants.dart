class wakeword_constants{
  static const List<String> wakeWordStartDialog = ['buddie', 'buddy', 'hi, buddy', 'hi, buddie', 'body'];
  static const List<String> wakeWordEndDialog = ['just listen', 'buddie, just listen', 'just listen, buddie', 'buddy, just listen', 'just listen buddy'];
  static const List<String> voiceVerificationPhrases = [
    'Hey, let’s hear your voice! Say: \n"Buddie, what\'s on my schedule today?"', 
    'Great! Next, could you say: \n"Buddie, what were the action items from the meeting?"', 
    'Almost there! Finally, please say: \n"Buddie, any updates from my last chat with friends?"',
    'Well done! You\'re all set up. \nJust say \n"Hi buddie, let\'s get started"'
  ];
  static const List<String> welcomePhrases = [
    'Buddie, what\'s on my schedule today?',
    'Buddie, what were the action items from the meeting?',
    'Buddie, any updates from my last chat with friends?',
    'Hi buddie, let\'s get started',
  ];
}
