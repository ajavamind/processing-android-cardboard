/*
  Example Processing VR sketch using Google Android Cardboard SDK
  Display OBJ shape
  
  This source code is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License version 2.1 as published by the Free Software Foundation.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General
  Public License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
*/


/**
 * Description
 * This Android app is an example Cardboard VR program coded using the Processing for Android
 * library and the Google Cardboard Android SDK.
 *
 * <p/>
 * The Processing library has an abstraction layer for OPENGL making it possible
 * to write an Android Cardboard app without needing direct Android OPENGL calls.
 * Using Processing with Cardboard SDK is an alternative for writing Android VR applications.
 *
 * <p/>
 * Cardboard SDK for Android 0.5.5
 * <p/>
 * Minimum Android API 4.4 (19)
 * <p/>
 * Tested with Sony Z1S phone, 1920x1080 pixel display, running Android version 5.0.2, and
 * hardware accelerated GPU
 *
 * <p/>
 * Issues:
 * Distortion correction is disabled because the Cardboard correction feature does not work well
 * The display is not distorted enough to matter with my Unofficial cardboard viewer lens and
 * home made viewer with stereoscopic quality lens.
 * <p/>
 *
 * notes:
 * The magnet trigger does not work well with my phone so I use new convert tap to trigger feature
 * available in Cardboard V2.
 * <p/>
 * Changes made to Processing-Android core library:
 * <p/>
 * PApplet extends CardboardActivity
 * <p/>
 * SketchSurfaceView extends CardboardView
 * <p/>
 * SketchSurfaceViewGL extends CardboardView
 * <p/>
 * CardboardView rendering uses CardboardView.Renderer
 * <p/>
 * CardboardView.StereoRenderer code is also available
 * <p/>
 * PStereo class added to Processing core for stereo view control
 * <p/>
 *
 *
 *
 * Cardboard is a trademark of Google Inc.
 */

import android.content.Context;
import android.os.Bundle;
import android.os.Vibrator;
import android.view.KeyEvent;
import com.google.vrtoolkit.cardboard.CardboardView;
import com.google.vrtoolkit.cardboard.HeadTransform;

import processing.core.PStereo;

    com.google.vrtoolkit.cardboard.CardboardView cardboardView;
    private android.os.Vibrator vibrator;
    PImage[] photo = null;
    PImage[] photoRight = null;
    PImage backgroundLeft = null;
    PImage backgroundRight = null;

    static final float STARTX = 0f;
    static final float STARTY = 0f;
    static final float STARTZ = 10f;
    static final int XBOUND = 9;
    static final int YBOUND = 10;
    static final int ZBOUND_IN = 4;
    static final int ZBOUND_OUT = 36;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        vibrator = (android.os.Vibrator) getSystemService(android.content.Context.VIBRATOR_SERVICE);
        cardboardView = (com.google.vrtoolkit.cardboard.CardboardView) surfaceView;
        //cardboardView.setAlignmentMarkerEnabled(false);
        //cardboardView.setSettingsButtonEnabled(false);
        setCardboardView(cardboardView);
        cardboardView.setDistortionCorrectionEnabled(false);
        //cardboardView.setDistortionCorrectionEnabled(true);
        cardboardView.setChromaticAberrationCorrectionEnabled(false);
        //cardboardView.setChromaticAberrationCorrectionEnabled(true);
        //cardboardView.setVRModeEnabled(false); // sets Monocular mode
         setConvertTapIntoTrigger(true);

    }

    //    @Override
    public void onCardboardTrigger() {
        // user feedback
        vibrator.vibrate(50);
        resetTracker();
    }

    @Override
    protected void onPause() {
        super.onPause();
        // The following call pauses the rendering thread.
        // If your OpenGL application is memory intensive,
        // you should consider de-allocating objects that
        // consume significant memory here.
        cardboardView.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        // The following call resumes a paused rendering thread.
        // If you de-allocated graphic objects for onPause()
        // this is a good place to re-allocate them.
        cardboardView.onResume();
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();
        // TODO release image resources
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Processing sketch for the Android app starts here.
    //

    float rotx = 0; //PI / 4;
    float roty = 0; //PI / 4;
    PShape rocket;

    float nearPlane = .1f;
    float farPlane = 1000f;
    float convPlane = 20.0f;
    float eyeSeparation;
    float fieldOfViewY = 45f;
    float cameraPositionX = STARTX;
    float cameraPositionY = STARTY;
    float cameraPositionZ = STARTZ;
    PStereo stereo = null;
    float[] headView = new float[16];

    @Override
    public void settings() {
        // set size to full screen dimensions
        //size(displayWidth, displayHeight, P3D);  // equivalent to OPENGL
        // Processing variables displayWidth and displayHeight are your phone screen dimensions
        size(displayWidth, displayHeight, OPENGL);
		orientation(LANDSCAPE);
        println("settings()");
    }

    /**
     * One time initial call to set up your Processing sketch variables, etc.
     */
    @Override
    public void setup() {
        background(0);
        rocket = loadShape("obj/rocket.obj");

        /* second constructor, custom eye separation, custom convergence */
        stereo = new PStereo(
                this, width, height, eyeSeparation, fieldOfViewY,
                nearPlane,
                farPlane, PStereo.StereoType.SIDE_BY_SIDE,
                convPlane);

        //println("Screen Width="+ width + " Height="+height);
        // start only needs to be called repeatedly if you are
        // changing camera position, which we are doing
        stereo.start(
                cameraPositionX, cameraPositionY, cameraPositionZ,
                0f, 0f, -1f,  // directionX, directionY, directionZ
                0f, 1f, 0f);  // upX, upY, upZ
        cardboardView.resetHeadTracker();

    }

    void drawShape(PShape s) {
        pushMatrix();
        scale(.01f);
        rotateX(rotx);
        rotateY(roty);
        rotateZ(PI);
        shape(s);
        popMatrix();
    }

    public void mouseDragged() {
        float rate = 0.01f;
        rotx += (pmouseY - mouseY) * rate;
        roty += (mouseX - pmouseX) * rate;
    }

    void resetTracker() {
        cameraPositionX = STARTX;
        cameraPositionY = STARTY;
        cameraPositionZ = STARTZ;
        cardboardView.resetHeadTracker();
    }

    @Override
    public void headTransform(com.google.vrtoolkit.cardboard.HeadTransform headTransform) {
        float[] quat = new float[4];
        headTransform.getQuaternion(quat, 0);
        // normalize quaternion
        float length = (float) Math.sqrt(quat[0] * quat[0] + quat[1] * quat[1] + quat[2] * quat[2] + quat[3] * quat[3]);
        int DIV = 10;
        float lowSpeed = .01f;  //.005f;
        float mediumSpeed = .02f;  //.01f;
        float highSpeed = .04f;  //.02f;
        float pitchSpeed = 0;
        float yawSpeed = 0;
        float rollSpeed = 0;
        if (length != 0) {
            int pitch = (int) ((quat[0] / length) * DIV);  // pitch up/down
            int yaw = (int) ((quat[1] / length) * DIV);  // yaw left/ right
            int roll = (int) ((quat[2] / length) * DIV);  // roll left/right
            //int w = (int) ((quat[3] / length) * DIV);  //
            //Log.d(TAG, "normalized quaternion " + pitch + " " + yaw + " " + roll );

            if (pitch >= 3)
                pitchSpeed = -highSpeed;
            else if (pitch <= -3)
                pitchSpeed = highSpeed;
            else if (pitch == 2)
                pitchSpeed = -mediumSpeed;
            else if (pitch == -2)
                pitchSpeed = mediumSpeed;
            else if (pitch == 1)
                pitchSpeed = -lowSpeed;
            else if (pitch == -1)
                pitchSpeed = lowSpeed;
            else
                pitchSpeed = 0;

            if (yaw >= 3)
                yawSpeed = -highSpeed;
            else if (yaw <= -3)
                yawSpeed = highSpeed;
            else if (yaw == 2)
                yawSpeed = -mediumSpeed;
            else if (yaw == -2)
                yawSpeed = mediumSpeed;
            else if (yaw == 1)
                yawSpeed = -lowSpeed;
            else if (yaw == -1)
                yawSpeed = lowSpeed;
            else
                yawSpeed = 0;

            if (roll >= 3)
                rollSpeed = -highSpeed;
            else if (roll <= -3)
                rollSpeed = highSpeed;
            else if (roll == 2)
                rollSpeed = -mediumSpeed;
            else if (roll == -2)
                rollSpeed = mediumSpeed;
            else if (roll == 1)
                rollSpeed = -lowSpeed;
            else if (roll == -1)
                rollSpeed = lowSpeed;
            else
                rollSpeed = 0;

            if ((cameraPositionX > XBOUND && yawSpeed < 0) ||
                    (cameraPositionX < -XBOUND && yawSpeed > 0) ||
                    (cameraPositionX <= XBOUND && cameraPositionX >= -XBOUND))
                cameraPositionX += yawSpeed;


            if ((cameraPositionY > YBOUND && pitchSpeed < 0) ||
                    (cameraPositionY < -YBOUND && pitchSpeed > 0) ||
                    (cameraPositionY <= YBOUND && cameraPositionY >= -YBOUND))
                cameraPositionY += pitchSpeed;

            if ((cameraPositionZ > ZBOUND_IN && rollSpeed < 0) ||
                    (cameraPositionZ < ZBOUND_OUT && rollSpeed > 0) ||
                    (cameraPositionZ <= ZBOUND_OUT && cameraPositionZ >= ZBOUND_IN))
                cameraPositionZ += rollSpeed;

//            Log.d(TAG, "Normalized quaternion " + pitch + " " + yaw + " " + roll + " Camera position "+ cameraPositionX + " " + cameraPositionY + " " + cameraPositionZ);
        } else {
            //Log.d(TAG, "Quaternion 0");
        }

//        headTransform.getHeadView(headView, 0);
//
//        if (!Float.isNaN(headView[0])) {
//            Log.d(TAG, "headView"  + " "+ headView[0] + " " + headView[1] + " " + headView[2] + " " + headView[3] + " " );
//            Log.d(TAG, "        "  +  " "+ headView[4] + " " + headView[5] + " " + headView[6] + " " + headView[7] + " " );
//            Log.d(TAG, "        "  +  " "+ headView[8] + " " + headView[9] + " " + headView[10] + " " + headView[11] + " " );
//            Log.d(TAG, "        "  +  " "+ headView[12] + " " + headView[13] + " " + headView[14] + " " + headView[15] + " " );
//        }

    }

    /**
     * Draw left eye. Called when VRMode enabled.
     */
    @Override
    public void drawLeft() {
        stereo.left();
        drawShape(rocket);
    }

    /**
     * Draw right eye. Called when VRMode enabled.
     */
    @Override
    public void drawRight() {
        stereo.right();
        drawShape(rocket);
   }

    /**
     * Processing draw function. Called before drawLeft and drawRight.
     */
    @Override
    public void draw() {
        //println("draw()");
        stereo.start(
                cameraPositionX, cameraPositionY, cameraPositionZ,
                0f, 0f, -1f,  // directionX, directionY, directionZ
                0f, 1f, 0f);  // upX, upY, upZ
        background(0);
    }

    int KEYCODE_MEDIA_NEXT = android.view.KeyEvent.KEYCODE_MEDIA_NEXT;   // RIGHT
    int KEYCODE_MEDIA_PREVIOUS = android.view.KeyEvent.KEYCODE_MEDIA_PREVIOUS;   // LEFT
    int KEYCODE_MEDIA_FAST_FORWARD = android.view.KeyEvent.KEYCODE_MEDIA_FAST_FORWARD;    // UP
    int KEYCODE_MEDIA_REWIND = android.view.KeyEvent.KEYCODE_MEDIA_REWIND;    // DOWN
    int KEYCODE_ENTER = android.view.KeyEvent.KEYCODE_ENTER;

    public void keyPressed() {
        println("keyCode=" + keyCode);
        //Log.d(TAG, "keyCode=" + keyCode);

        if (keyCode == LEFT || keyCode == KEYCODE_MEDIA_PREVIOUS) {
            rotx += PI / 4;
        } else if (keyCode == RIGHT || keyCode == KEYCODE_MEDIA_NEXT) {
            rotx -= PI / 4;
        } else if (keyCode == UP || keyCode == KEYCODE_MEDIA_FAST_FORWARD) {
            roty += PI / 4;
        } else if (keyCode == DOWN || keyCode == KEYCODE_MEDIA_REWIND) {
            roty -= PI / 4;
        } else if (keyCode == KEYCODE_ENTER) {
            resetTracker();
        }
    }