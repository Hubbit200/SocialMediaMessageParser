import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;

JFileChooser chooser = new JFileChooser();
FileNameExtensionFilter jsonFilter = new FileNameExtensionFilter("JSON", "json");
FileNameExtensionFilter txtFilter = new FileNameExtensionFilter("TXT", "txt");

int state = 0;
PImage bg, menuBg, analyse, analyseP, file, fileP, tg, tgP, ig, igP, wh, whP;
PFont bold, extraBold;
String filePathTg = "", filePathWh = "", filePathIg = "", fileNameTg = "", fileNameWh = "", fileNameIg = "";
JSONObject dataTg, dataIg;
String[] dataWh;

class info {
  private String name = "", type = "", app = "";
  private int totalMessages;

  private info(String n, String t, String a, int m) {
    name = n;
    type = t;
    app = a;
    totalMessages = m;
  }
  public String getName() { 
    return name;
  }
  public String getType() { 
    return type;
  }
  public int getTotal() {
    return totalMessages;
  }
  public String getApp() {
    return app;
  }
}

info chatInfoTg, chatInfoWh, chatInfoIg, chatInfo;
IntDict messagesPerPerson = new IntDict();
IntDict words = new IntDict();
IntDict dates = new IntDict();
StringList filterWords = new StringList("can", "ver", "ahora", "sé", "we", "about", "así", "tú", "voy", "tengo", "solo", "del", "está", "pues", "hay", "más", "then", "get", "i'll", "that", "like", "don't", "or", "as", "she", "estoy", "muy", "your", "do", "on", "if", "at", "was", "in", "for", "but", "como", "o", "is", "it's", "have", "so", "with", "just", "i", "the", "q", "no", "y", "a", "de", "que", "me", "la", "el", "en", "es", "lo", "pero", "si", "se", "por", "un", "yo", "tu", "", "una", "mi", "las", "con", "te", "tu", "qué", "para", "d", "los", "le", "ha", "he", "ya", "eso", "to", "you", "and", "it", "be", "me", "al", "of", "not", "my", "i'm");
boolean wordFilter = true;
int timeFrame, min, max;
PVector lastLinePos = new PVector(0, 0);

// Setup and resource loading ----
public void setup() {
  size(1200, 800);
  textAlign(CENTER);
  fill(255);
  rectMode(CORNERS);
  imageMode(CENTER);
  loadResources();
  textFont(extraBold);
  textSize(20);
}

private void loadResources() {
  bg = loadImage("bg.png");
  menuBg = loadImage("menubg.png");
  analyse = loadImage("Analyse_U.png");
  analyseP = loadImage("Analyse_P.png");
  file = loadImage("Browse_U.png");
  fileP = loadImage("Browse_P.png");
  tg = loadImage("Tele_U.png");
  tgP = loadImage("Tele_P.png");
  ig = loadImage("Insta_U.png");
  igP = loadImage("Insta_P.png");
  wh = loadImage("What_U.png");
  whP = loadImage("What_P.png");
  bold = createFont("Montserrat-Bold.ttf", 20);
  extraBold = createFont("Montserrat-ExtraBold.ttf", 30);
}

// Draw calls ----
public void draw() {
  // If in pre-analysis menu
  if (state==0) {
    background(menuBg);
    if (mouseY>height-200)image(analyseP, width/4.5, height-130);
    else image(analyse, width/4.5, height-130);

    if (mouseY<height-200 && mouseX<400) {
      image(fileP, width/5, height/1.5);
      image(tgP, width/5, height/2.5);
    } else { 
      image(file, width/5, height/1.5);
      image(tg, width/5, height/2.5);
    }
    text(fileNameTg, width/5.75, height/1.48);
    if (mouseY<height-200 && mouseX>400 && mouseX<width-400) {
      image(fileP, width/2, height/1.5);
      image(igP, width/2, height/2.5);
    } else {
      image(file, width/2, height/1.5);
      image(ig, width/2, height/2.5);
    }
    text(fileNameIg, width/2.08, height/1.48);
    if (mouseY<height-200 && mouseX>width-400) {
      image(fileP, width/5*4, height/1.5);
      image(whP, width/5*4, height/2.5);
    } else {
      image(file, width/5*4, height/1.5);
      image(wh, width/5*4, height/2.5);
    }
    text(fileNameWh, width/5*3.87, height/1.48);
  // Else if already analysed
  } else if (state==1) {
    background(bg);
    noStroke();
    fill(255);
    text("Message Count", width/4, 380);
    if (wordFilter)text("Most common words (filter ON):", width/4*3, 160);
    else text("Most common words (filter OFF):", width/4*3, 160);

    // Message counts by username and in total
    fill(#5eb5f7);
    text(chatInfo.name + " (" + chatInfo.type + ")", width/2, 75);
    text(chatInfo.getTotal()+" messages in total", width/4, 160);
    fill(255);
    textFont(bold);
    textSize(20);
    int a = 0;
    for (int i = 0; i < messagesPerPerson.keyArray().length; i++) {
      if (!messagesPerPerson.keyArray()[i].equals("null")) {
        a++;
        text("- "+messagesPerPerson.keyArray()[i]+": "+messagesPerPerson.get(messagesPerPerson.keyArray()[i])+" messages", width/4, 160+30*a);
      }
    }

    // Most repeated words, with or without filtering
    fill(#5eb5f7);
    a = 0;
    for (int i = 0; i < 14; i++) {
      if (wordFilter) {
        while (filterWords.hasValue(words.keyArray()[a])) {
          a++;
        }
        writeWordInfo(a, i);
        a++;
      } else {
        writeWordInfo(a, i);
        a++;
      }
    }

    // Messages by month chart
    int x = 0;
    stroke(255);
    for (int i = int(dates.keyArray()[0].substring(0, 4)); i <= int(dates.keyArray()[dates.size()-1].substring(0, 4)); i++) {
      if (i == int(dates.keyArray()[0].substring(0, 4)) && i != int(dates.keyArray()[dates.size()-1].substring(0, 4))) {
        for (int o = int(dates.keyArray()[0].substring(5, 7)); o < 13; o++) {
          writeMonthInfo(i, o, x);
          x++;
        }
      } else if (i != int(dates.keyArray()[0].substring(0, 4)) && i == int(dates.keyArray()[dates.size()-1].substring(0, 4))) {
        for (int o = 1; o <= int(dates.keyArray()[dates.size()-1].substring(5, 7)); o++) {
          writeMonthInfo(i, o, x);
          x++;
        }
      } else if (int(dates.keyArray()[0].substring(0, 4)) == int(dates.keyArray()[dates.size()-1].substring(0, 4))) {
        for (int o = int(dates.keyArray()[0].substring(5, 7)); o <= int(dates.keyArray()[dates.size()-1].substring(5, 7)); o++) {
          writeMonthInfo(i, o, x);
          x++;
        }
      } else {
        for (int o = 1; o < 13; o++) {
          writeMonthInfo(i, o, x);
          x++;
        }
      }
    }
    textSize(30);
    fill(255);
    noStroke();
    // Stop looping, as on-screen data will not need further updating
    noLoop();
  }
}

// Draw month on chart - point, month, and number
void writeMonthInfo(int i, int m, int x) {
  textSize(16);
  if (m == 1)text(i, 80+1050/(timeFrame-1)*x, 750);
  else text(m, 80+1050/(timeFrame-1)*x, 750);
  textSize(14);
  if (m>9 && dates.hasKey(i+"-"+m)) {
    fill(#5eb5f7);
    text(dates.get(i+"-"+m), 80+1050/(timeFrame-1)*x, map(dates.get(i+"-"+m), min, max, 710, 460)-15);
    fill(255);
    if (lastLinePos.x!=0 || lastLinePos.y!=0)line(lastLinePos.x, lastLinePos.y, 80+1050/(timeFrame-1)*x, map(dates.get(i+"-"+m), min, max, 710, 460));
    lastLinePos = new PVector(80+1050/(timeFrame-1)*x, map(dates.get(i+"-"+m), min, max, 710, 460));
    circle(80+1050/(timeFrame-1)*x, map(dates.get(i+"-"+m), min, max, 710, 460), 10);
    
  } else if (dates.hasKey(i+"-0"+m)) { 
    fill(#5eb5f7);
    text(dates.get(i+"-0"+m), 80+1050/(timeFrame-1)*x, map(dates.get(i+"-0"+m), min, max, 710, 460)-15);
    fill(255);
    if (lastLinePos.x!=0 || lastLinePos.y!=0)line(lastLinePos.x, lastLinePos.y, 80+1050/(timeFrame-1)*x, map(dates.get(i+"-0"+m), min, max, 710, 460));
    lastLinePos = new PVector(80+1050/(timeFrame-1)*x, map(dates.get(i+"-0"+m), min, max, 710, 460));
    circle(80+1050/(timeFrame-1)*x, map(dates.get(i+"-0"+m), min, max, 710, 460), 10);
    
  } else {
    fill(#5eb5f7);
    text("0", 80+1050/(timeFrame-1)*x, 695);
    fill(255);
    if (lastLinePos.x!=0 || lastLinePos.y!=0)line(lastLinePos.x, lastLinePos.y, 80+1050/(timeFrame-1)*x, 710);
    lastLinePos = new PVector(80+1050/(timeFrame-1)*x, 710); 
    circle(80+1050/(timeFrame-1)*x, 710, 10);
  }
}

// Write info for specified word from array, correcting for common uppercase words (bacause all input is converted to lowercase on analysis)
void writeWordInfo(int p, int pos) {
  if (pos<7) {
    if (words.keyArray()[p].equals(":d"))text(":D -> "+words.get(words.keyArray()[p])+" times", 770, 200+27*pos);
    else if (words.keyArray()[p].equals("i"))text("I -> "+words.get(words.keyArray()[p])+" times", 770, 200+27*pos);
    else if (words.keyArray()[p].equals("i'm"))text("I'm -> "+words.get(words.keyArray()[p])+" times", 770, 200+27*pos);
    else text(words.keyArray()[p]+" -> "+words.get(words.keyArray()[p])+" times", 770, 200+27*pos);
  } else {
    if (words.keyArray()[p].equals(":d"))text(":D -> "+words.get(words.keyArray()[p])+" times", 1000, 200+27*(pos-7));
    else if (words.keyArray()[p].equals("i"))text("I -> "+words.get(words.keyArray()[p])+" times", 1000, 200+27*(pos-7));
    else if (words.keyArray()[p].equals("i'm"))text("I'm -> "+words.get(words.keyArray()[p])+" times", 1000, 200+27*(pos-7));
    else text(words.keyArray()[p]+" -> "+words.get(words.keyArray()[p])+" times", 1020, 200+27*(pos-7));
  }
}

// Actions on mouse pressed ----
void mousePressed() {
  // If on pre-analysis menu
  if (state==0) {
    // If mouse over file input buttons
    if (mouseY<height-200) {
      if (mouseX<400) {
        chooser.setFileFilter(jsonFilter);
        int returnVal = chooser.showOpenDialog(null);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
          filePathTg = chooser.getSelectedFile().getAbsolutePath();
          fileNameTg = chooser.getSelectedFile().getName();
          int i = 20;
          while (textWidth(fileNameTg)>200) {
            i--;
            fileNameTg = chooser.getSelectedFile().getName().substring(0, i);
          }

          dataTg = loadJSONObject(filePathTg);
        }
      } else if (mouseX>width-400) {
        chooser.setFileFilter(txtFilter);
        int returnVal = chooser.showOpenDialog(null);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
          filePathWh = chooser.getSelectedFile().getAbsolutePath();
          fileNameWh = chooser.getSelectedFile().getName();
          int i = 20;
          while (textWidth(fileNameWh)>200) {
            i--;
            fileNameWh = chooser.getSelectedFile().getName().substring(0, i);
          }

          dataWh = loadStrings(filePathWh);
        }
      } else {
        chooser.setFileFilter(jsonFilter);
        int returnVal = chooser.showOpenDialog(null);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
          filePathIg = chooser.getSelectedFile().getAbsolutePath();
          fileNameIg = chooser.getSelectedFile().getName();
          int i = 20;
          while (textWidth(fileNameIg)>200) {
            i--;
            fileNameIg = chooser.getSelectedFile().getName().substring(0, i);
          }

          dataIg = loadJSONObject(filePathIg);
        }
      }
    // If mouse over analyse button and at least one file selected
    } else if (dataTg != null || dataWh != null || dataIg != null) {
      state=-1;
      background(0);
      textSize(30);
      text("Analysing...", width/2, height/2);
      delay(10);
      // Don't analyse chat type if no file selected (null)
      if (dataTg != null)startTelegramAnalysis();
      if (dataWh != null)startWhatsAppAnalysis();
      if (dataIg != null)startInstagramAnalysis();
      // Complete analysis and change state to data presentation screen
      finishAnalysis();
      state = 1;
    }
  }
}

// Analysis functions for each messaging service file type ----
public void startTelegramAnalysis() {
  // Get JSONArray from JSON input file
  JSONArray messages = dataTg.getJSONArray("messages");
  JSONObject message;
  // Loop over all items in JSONArray and check if each one is a message
  for (int i = 0; i < messages.size(); i++) {
    message = messages.getJSONObject(i);
    if (message.getString("type").equals("message")) {
      // If item is a message, add to relevant date, increment messages for relevant username, and add words to word array
      dates.add(message.getString("date").substring(0, 7), 1);
      messagesPerPerson.add(message.get("from").toString(), 1);
      try {
        String[] text = message.getString("text").replace("\\w", "").toLowerCase().split("\\s+");
        for (int t=0; t<text.length; t++) {
          words.add(text[t], 1);
        }
      } 
      catch(Exception e) {
      }
    }
  }
  // Set chat information variable
  chatInfoTg = new info(dataTg.getString("name"), dataTg.getString("type"), "telegram", 0);
}

public void startWhatsAppAnalysis() {
  StringList people = new StringList();
  // Loop over all lines of WhatsApp input file
  for (String s : dataWh) {
    if (match(s, "[0-9]{2}+/[0-9]{2}/[0-9]{4}, [0-9]{2}:[0-9]{2}.*") != null && !split(s, " - ")[1].equals("Messages and calls are end-to-end encrypted. No one outside of this chat, not even WhatsApp, can read or listen to them. Tap to learn more.") && !split(s, " - ")[1].equals("You blocked this contact. Tap to unblock.") && !split(s, " - ")[1].equals("You unblocked this contact.")) {
      // If line is a message, add to relevant date, increment messages for relevant username, and add words to word array
      String person = split(s, ":")[1].substring(5);
      if (!people.hasValue(person)) people.append(person);
      dates.add(s.substring(6, 10)+"-"+s.substring(3, 5), 1);
      messagesPerPerson.add(person, 1);
      if (!s.substring(split(s.substring(20), ": ")[0].length()+22).equals("<Media omitted>") && !s.substring(split(s.substring(20), ": ")[0].length()+22).equals("Missed voice call") && !s.substring(split(s.substring(20), ": ")[0].length()+22).equals("Missed group video call")) {
        String[] text = s.substring(split(s.substring(20), ": ")[0].length()+22).replace("\\w", "").toLowerCase().split("\\s+");
        for (int t=0; t<text.length; t++) {
          words.add(text[t], 1);
        }
      }
    }
  }
  // Set chat information variable
  String peopleString = "";
  for (String p : people) {
    peopleString += p + ", ";
  }
  chatInfoWh = new info(peopleString.substring(0, peopleString.length() - 2), (people.size() > 2) ? "Group chat" : "Private chat", "whatsapp", 0);
}

public void startInstagramAnalysis() {
  StringList people = new StringList();
  // Get JSONArray from JSON input file
  JSONArray messages = dataIg.getJSONArray("messages");
  JSONObject message;
  // Loop over all items in JSONArray and check if each one is a message
  for (int i = 0; i < messages.size(); i++) {
    message = messages.getJSONObject(i);
    if (message.getString("type").equals("Generic") && message.getString("content")!=null && !message.getString("content").equals("Liked a message")) {
      // If item is a message, add username to username array if not already in it, add message to relevant date, increment messages for relevant username, and add words to word array
      if (!people.hasValue(message.get("sender_name").toString())) people.append(message.get("sender_name").toString());
      dates.add(new java.text.SimpleDateFormat("yyyy-MM").format(new java.util.Date (message.getLong("timestamp_ms"))), 1);
      messagesPerPerson.add(message.get("sender_name").toString(), 1);
      try {
        String temp = new String(message.getString("content").getBytes("latin1"), "utf8");
        String[] text = temp.replace("\\w", "").toLowerCase().split("\\s+");
        for (int t=0; t<text.length; t++) {
          words.add(text[t], 1);
        }
      } 
      catch(Exception e) {
      }
    }
  }
  // Set chat information variable
  String peopleString = "";
  for (String p : people) {
    peopleString += p + ", ";
  }
  chatInfoIg = new info(peopleString.substring(0, peopleString.length() - 2), (people.size() > 2) ? "Group chat" : "Private chat", "instagram", 0);
}

// Last steps of analysis
public void finishAnalysis() {
  // Count total messages
  int sum = 0;
  for (int value : messagesPerPerson.valueArray()) {
    sum += value;
  }
  // Set chat information for window title
  if (dataTg != null)chatInfo = new info(chatInfoTg.name, chatInfoTg.type, "", sum);
  else if (dataWh != null)chatInfo = new info(chatInfoWh.name, chatInfoWh.type, "", sum);
  else chatInfo = new info(chatInfoIg.name, chatInfoIg.type, "", sum);

  // Sort date keys and sort words in inverse order to get most common first
  dates.sortKeys();
  words.sortValuesReverse();

  // Set total time range of messages
  if (int(dates.keyArray()[0].substring(0, 4))==int(dates.keyArray()[dates.size()-1].substring(0, 4))) timeFrame = int(dates.keyArray()[dates.size()-1].substring(5, 7))-int(dates.keyArray()[0].substring(5, 7))+1;
  else if (int(dates.keyArray()[0].substring(0, 4))+1==int(dates.keyArray()[dates.size()-1].substring(0, 4))) timeFrame = (13-int(dates.keyArray()[0].substring(5, 7)))+int(dates.keyArray()[dates.size()-1].substring(5, 7));
  else timeFrame = (13-int(dates.keyArray()[0].substring(5, 7))) + int(dates.keyArray()[dates.size()-1].substring(5, 7)) + ((int(dates.keyArray()[dates.size()-1].substring(0, 4))-1-int(dates.keyArray()[0].substring(0, 4)))*12);

  // Create array of dates sorted with the sorted date key array
  IntDict sortedDates = new IntDict(dates.keyArray(), dates.valueArray());
  sortedDates.sortValues();
  min = sortedDates.valueArray()[0];
  max = sortedDates.valueArray()[sortedDates.size()-1];
}
