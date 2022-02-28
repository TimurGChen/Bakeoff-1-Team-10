import processing.core.PApplet;

import java.awt.*;
import java.util.ArrayList;
import java.util.Collections;



//when in doubt, consult the Processsing reference: https://processing.org/reference/

int margin = 200; //set the margin around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
final float ShrinkRate = 0.618F;
Robot robot; //initialized in setup

int numRepeats = 1; //sets the number of times each button repeats in the test



//@Override
//public void settings() {
//    size(700,700); // set the size of the window
//}

public void setup()
{
    size(700,700); 
    //noCursor(); // hides the system cursor if you want
    noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
    textFont(createFont("Arial",16)); //sets the font to Arial size 16
    textAlign(CENTER);
    frameRate(60); //normally you can't go much higher than 60 FPS.
    ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
    //rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

    try {
        robot = new Robot(); //create a "Java Robot" class that can move the system cursor
    } catch (AWTException e) {
        e.printStackTrace();
    }

    //===DON'T MODIFY MY RANDOM ORDERING CODE==
    for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
        // number of buttons in 4x4 grid
        for (int k = 0; k < numRepeats; k++)
            // number of times each button repeats
            trials.add(i);

    Collections.shuffle(trials); // randomize the order of the buttons
    System.out.println("trial order: " + trials); //print out order for reference

    surface.setLocation(0,0);// put window in top left corner of screen (doesn't always work)
}


public void draw()
{
    background(0); //set background to black

    if (trialNum >= trials.size()) //check to see if test is over
    {
        float timeTaken = (finishTime-startTime) / 1000f;
        float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f),0,100);
        fill(255); //set fill color to white
        //write to screen (not console)
        text("Finished!", width / 2, height / 2);
        text("Hits: " + hits, width / 2, height / 2 + 20);
        text("Misses: " + misses, width / 2, height / 2 + 40);
        text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
        text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
        text("Average time for each button: " + nf((timeTaken)/(float)(hits+misses),0,3) + " sec", width / 2, height / 2 + 100);
        text("Average time for each button + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty),0,3) + " sec", width / 2, height / 2 + 140);
        return; //return, nothing else to do now test is over
    }

    fill(255); //set fill color to white
    text((trialNum + 1) + " of " + trials.size(), 40, 20); //display what trial the user is on

    for (int i = 0; i < 16; i++)// for all button
        drawButton(i); //draw button

    // draw guide path to next & look ahead buttons
    Rectangle nxtBounds = getButtonLocation(trials.get(trialNum));
    guidePath(mouseX, mouseY, nxtBounds, false);
    if (trialNum < trials.size()-1) { // no look ahead on last round
        Rectangle lkaBounds = getButtonLocation(trials.get(trialNum + 1));
        int[] nxtCoordinate = getButtonCenter(nxtBounds);
        guidePath(nxtCoordinate[0], nxtCoordinate[1], lkaBounds, true);
    }
    laserPtr();
}

private void laserPtr() {
    // set stroke & fill
//        stroke(255, 0, 0, 200);
//        strokeWeight(2F);
//        noFill();

//        ellipse(mouseX, mouseY, 40, 40); //draw user cursor as a circle with a diameter of 20

    // center dot
    fill(255, 0,0,200);
    ellipse(mouseX, mouseY, 10, 10);

    // cross
    // set stroke & fill
    stroke(255, 0, 0, 200);
    strokeWeight(2F);
    line(mouseX-20, mouseY, mouseX+20, mouseY);
    line(mouseX, mouseY-20, mouseX, mouseY+20);
    noStroke();

}

private void guidePath(int x, int y, Rectangle target, boolean lookAhead) {
    // draws guide path from (x, y) to button
    int[] targetCoordinate = getButtonCenter(target);
    strokeWeight(5);
    stroke(255F, 127F,39F, lookAhead?50:150);
    line(x, y, targetCoordinate[0], targetCoordinate[1]);
    noStroke();
}

private void highlightOnHover(int idx) {
    Rectangle bounds = getButtonLocation(idx);
    if ((mouseX > bounds.x
            && mouseX < bounds.x + bounds.width)
            && (mouseY > bounds.y
            && mouseY < bounds.y + bounds.height)) {
        stroke(255,255,255, 150);
        strokeWeight(15);
    } else {
        noStroke();
    }
}

private int[] getButtonCenter(Rectangle bounds) { // get center coordinate of a button
    int[] coordinate = new int[2];
    coordinate[0] = bounds.x + bounds.width/2;
    coordinate[1] = bounds.y + bounds.height/2;
    return coordinate;
}

public void mousePressed() // test to see if hit was in target!
{
    if (trialNum >= trials.size()) //check if task is done
        return;

    if (trialNum == 0) //check if first click, if so, record start time
        startTime = millis();

    if (trialNum == trials.size() - 1) //check if final click
    {
        finishTime = millis();
        //write to terminal some output:
        System.out.println("we're all done!");
    }

    Rectangle bounds = getButtonLocation(trials.get(trialNum));

    //check to see if cursor was inside button
    if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
    {
        System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
        hits++;
    } else
    {
        System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
        misses++;
    }

    trialNum++; // Increment trial number

    //in this example design, I move the cursor back to the middle after each click
//        robot.mouseMove(width/2, (height)/2); //on click, move cursor to roughly center of window!
}

//probably shouldn't have to edit this method
public Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
    int x = (i % 4) * (padding + buttonSize) + margin;
    int y = (i / 4) * (padding + buttonSize) + margin;

    return new Rectangle(x, y, buttonSize, buttonSize);
}

//you can edit this method to change how buttons appear
public void drawButton(int i)
{
    Rectangle bounds = getButtonLocation(i);

    if (trials.get(trialNum) == i) // see if current button is the target
        fill(255, 0, 0); // if so, fill red target
//            fill(255, 255, 0); // Yellow target
    else if (trialNum+1 < trials.size() && trials.get(trialNum+1) == i) // look ahead button
        fill(255, 100, 100, 150); // fill translucent red
//            fill(255, 255,0,100); // Yellow Look-Ahead
    else
        fill(200); // if not, fill gray

    highlightOnHover(i);

    rect(bounds.x, bounds.y, bounds.width, bounds.height);

    // additional patterns for target
    if (trials.get(trialNum) == i) {
        fill(255, 255, 255);
        rect(bounds.x+bounds.width*(1-ShrinkRate)/2,
                bounds.y+bounds.width*(1-ShrinkRate)/2,
                bounds.width*ShrinkRate,
                bounds.height*ShrinkRate);
        fill(255, 0, 0);
        rect(bounds.x+bounds.width*(1-ShrinkRate*ShrinkRate)/2,
                bounds.y+bounds.width*(1-ShrinkRate*ShrinkRate)/2,
                bounds.width*ShrinkRate*ShrinkRate,
                bounds.height*ShrinkRate*ShrinkRate);
    }
}

public void mouseMoved()
{
    //can do stuff everytime the mouse is moved (i.e., not clicked)
    //https://processing.org/reference/mouseMoved_.html
}

public void mouseDragged()
{
    //can do stuff everytime the mouse is dragged
    //https://processing.org/reference/mouseDragged_.html
}

public void keyPressed()
{
    //can use the keyboard if you wish
    //https://processing.org/reference/keyTyped_.html
    //https://processing.org/reference/keyCode.html
}
