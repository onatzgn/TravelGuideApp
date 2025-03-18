# **Application:**

## **Features:**

-	Content will be displayed on the homepage based on the selected city.
 
-	Users will create journals about the places they visit. (Route locations will be added, users can write their own entries, other people can like the journal, and places within the journal can be saved.)
 
-	If a place is recognized, the user will receive a collectible item (stamp, badge, sticker).
 
-	After a place is recognized, users will be able to see comments and photos left by the people they follow at that location.
 
-	When the user is at a location and opens the camera, they will be able to leave a photo or comment for that place.
 
-	Social network interactions.
 
-	MapKit integration.


# **AR ve Camera Interactions:**

## **Features:**

-	The recognized location will be explained (both audio and text-based), with historical events displayed based on different time periods.
 
-	Photos from relevant historical periods will be shown to the user. The screen will be split into two: one side showing the live camera view, and the other displaying the historical photo.
 
-	Different sections of the location will be identified, and their names will be displayed on the screen. Users can tap on these information boxes to listen to or read detailed descriptions.
 
-	Users can point the camera at historical symbols, inscriptions, or motifs on artifacts to learn their meanings.
 
-	Lost or damaged historical structures can be digitally reconstructed and placed back in their original locations using AR technology.
 
-	Old Ottoman or Latin inscriptions can be scanned with AR and displayed as a digitally translated sign in the modern language.
 
-	In museums or open spaces, specific artifacts related to the location can be digitally displayed in AR, allowing users to rotate and examine them in 360 degrees. For example, the Kaşıkçı Elması at Topkapı Palace.


# **Backend:**

## **Features:**

-Social network interactions and database



# **Users**

## **Registered Members:**

-	They can create travel routes and write travel journals. They can read and explore routes created by others.
 
-	They can follow and be followed by other members.
 
-	They can collect badges by visiting places and showcase them on their profiles.
 
-	They can leave photos or comments at historical sites.
 
-	They can use the camera to explore historical artifacts and obtain information about them.


## **Administrators:**

-	They can manage CNN and AR content within the application.
 
-	They can add and edit interactive points and their labels.
 
-	They can organize and test datasets of historical site photos.
 
-	If a location classification fails, users can submit their photos to the system, and administrators can review these error reports.
 
-	They can review reported users and take actions such as issuing warnings.
 
-	They can review user complaints and requests regarding the application.


# **Components**

## **Journal:**

<img width="467" alt="Ekran Resmi 2025-03-18 12 05 23" src="https://github.com/user-attachments/assets/aa08bfa1-ffd0-475e-ae3b-933c9a862279" />

### **Features:**

-	When creating a travel journal, users will first add routes.
 
-	Each stop on the route will have a text section where users can write whatever they want.
 
-	The travel journal will display the following details:
		Number of Stops
		Total Distance (km)
		Journal Cover Image
		Journal Title
		Journal Description
		Number of Likes and Comments
		Author’s Username
  
-	Other users can save travel journals for easy access later.
 
-	Other users can comment on travel journals. (These comments are essential to keep the journal updated; users can mention any changes in the places listed on the route.)
 
-	Other users can like travel journals.
 
-	Travel journals will be visible both on the author’s profile and under the corresponding city on the homepage.


## **Route:**

<img width="415" alt="Ekran Resmi 2025-03-18 12 07 29" src="https://github.com/user-attachments/assets/affac89b-7d4b-4333-9f04-cfe6ea741169" />

### **Features:**

-	When the user is on the map, they will be able to select a route from their saved journals.
 
-	This route will guide the user along the path they need to follow.


## **Landmark Coin:**

<img width="153" alt="Ekran Resmi 2025-03-18 12 12 07" src="https://github.com/user-attachments/assets/d9601544-3cc1-4d98-8c6d-058540f10412" />

### **Features:**

-	When a location is recognized in Exploration Mode, the app will reward the user with a landmark coin.
 
-	The landmark coin given to the user will be unique to that location.
 
-	The landmark coins collected from different places will be displayed on the user’s profile.


## **Place Info Box:**

<img width="173" alt="Ekran Resmi 2025-03-18 12 14 37" src="https://github.com/user-attachments/assets/eda7ae75-3e38-4c46-be5c-a82badafc7fc" />

### **Features:**

-	This is a section on the map that provides information about the site.
 
-	If the user has selected a route, the stop number of the site within the route will be displayed at the bottom of the info box.
 
-	If the site has not been visited before, a lock icon will appear at the bottom right of the info box.
 
-	If people the user follows have previously visited this site and shared photos or comments, their profile pictures will be displayed at the top right of the info box.
 
-	The name of the site will be displayed at the bottom of the info box.


## **Place Info Panel:**

<img width="296" alt="Ekran Resmi 2025-03-18 12 15 47" src="https://github.com/user-attachments/assets/da911718-9467-4964-9597-deed720aedcc" />

### **Features:**

-	This is the panel that opens when the Historic Site Info Box is tapped.
 
-	Tags related to the site will be displayed (e.g., AR-supported, Has a landmark coin, etc.).
 
-	All followed users who have left a comment or photo for this site will be visible.
 
-	With the “Open in Maps” option, users can be redirected to Apple Maps for navigation when needed.
 
-	The landmark coin for the site will be prominently displayed.

## **Explore Button:**

<img width="436" alt="Ekran Resmi 2025-03-18 12 16 52" src="https://github.com/user-attachments/assets/4333bd33-53d9-4ae8-80a7-337312a2243d" />

### **Features:**

-	The Explore Button on the map allows the user to enter Exploration Mode.
 
-	When the camera is open, the Explore Button at the bottom will be used for image classification.
 
-	The user will press the button while the camera is open, and the image will be sent to the CNN model. If the model recognizes the site, the app will proceed to the description section. If the site is not recognized, the app will prompt the user to move to a clearer position with a better frontal view before taking another photo.


## **Historical Description Panel:**

<img width="406" alt="Ekran Resmi 2025-03-18 12 18 35" src="https://github.com/user-attachments/assets/04c2c287-601b-4dd9-9193-94cf3516767e" />

### **Features:**

-	This is the panel that will appear at the top of the screen after successful image classification.
 
-	If the user wants to identify another nearby site, they can press the X button and use the Explore Button again to recognize a new site.
 
-	The history of the site will be narrated in chronological order, starting from its construction date and covering significant events over time.
 
-	Both audio and text-based narration options will be available.


## **Object-Based Description Boxes:**

<img width="249" alt="Ekran Resmi 2025-03-18 12 20 06" src="https://github.com/user-attachments/assets/b9bcf01b-c583-4360-9feb-3a1f47d459bf" />

### **Features:**

-	While the camera is open, object detection will identify specific objects in real-time, and info boxes will appear over them.
 
-	As the camera moves, these info boxes will remain anchored to the detected objects.
 
-	Both audio and text-based narration options will be available.


## **Friend Activities Section:**

<img width="466" alt="Ekran Resmi 2025-03-18 12 21 29" src="https://github.com/user-attachments/assets/dba3493f-0beb-499d-9980-5c24853de2df" />

### **Features:**

-	The user can only see these activities if they are at the location.
 
-	When tapping on a friend’s profile picture, the photo or comment they added will be displayed on the screen.
 
-	If the user wants to add a comment or photo for the location, they can use the buttons below.



![Group 1000004626](https://github.com/user-attachments/assets/5b6167f1-f260-46d0-b703-5a8ae4112037)


