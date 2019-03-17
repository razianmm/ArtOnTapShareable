# ArtOnTapShareable
Shareable repo for demo app project

Hello!

Welcome to my app!

I am a junior-level iOS developer, and this project is meant to showcase some of the skills I’ve learnt since embarking on this career path. I hope to contribute these to any future project of which I am a part, and of course to continue learning new skills and best practices along the way.

About the app:

The idea for Art on Tap was conceived after a trip to the supermarket in Toronto. I noticed that a lot of the beer cans and bottles on sale have some pretty amazing art on them, and felt it was a shame to throw such great art in the recycling bin without a way to view it again. So, I decided to make an app to capture photos of the art and add them to a database, so that I could carry all that great art anytime and share it with friends.

As I mentioned, this project is meant to tick a lot of boxes in terms of hireable skills I’ve acquired. These include:

- Using CoreData to save, load, and manipulate data locally - including enabling multiple different users on same device

- Storing images in local file storage on device

- Using Firebase to make and parse API calls and save, load and manipulate data remotely for each user, including saving and retrieving images from cloud server

- Using Firebase to understand the user authentication process and how to handle security rules for user accounts

- Basic UI layout of iOS applications using auto-layout and constraints

- Basic flow of Views in iOS applications, using MVC architecture, including populating UI elements with relevant data

- Using Alerts and Actions to create user flow

- Passing data back and forth between views using segues and protocol/delegate methods

- Practice with checking for and unwrapping optional values

- Populating a TableView with data, update accordingly and implement other TableView delegate methods

- Using MapKit and map views to locate user, save user locations, and display map annotations

- Using basic GDC and multithreading/concurrency to handle asynchronous calls

- Using escaping closures and completion blocks to further handle asynchronous function calls and returns

- Using GitHub to practice good source control habits as well as security through .gitIgnore

- Using CocoaPods to install and manage custom libraries and frameworks

How it works:

The user signs up to a Firebase database with any e-mail address and password by tapping the ‘Sign Up’ button. They are then taken to a TableView which presents their saved beer art, with an option to sync to the database and retrieve previously saved beer art in case of a fresh app install.

By tapping the add button in the Navigation Bar, the user can use their devices camera to capture photos of art, and annotate them with certain data. These include using MapKit to find the user’s current location or add custom locations of which to keep track. When the art is added to the app, it is then displayed in the previously mentioned TableView, through which the user can tap on a TableView cell to view the art in more detail, and delete the art either locally or both locally and from the database.

In addition, I have also included a screen to display a map of the world, along with pins to display all the locations in which beer art has been saved, if any were added. There is also a separate screen where the user can completely clear all saved art and associated images either locally or from the database.

And that’s it! I hope you enjoy using this app, and have the opportunity to collect and display some great art along the way! Cheers.
