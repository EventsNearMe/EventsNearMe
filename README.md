# EventsNearMe

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Gather all types of events from Eventbrite in the local area. Users can search for an event. Events are listed in date order, or calendar view.


### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:**
- **Mobile:**
- **Story:**
- **Market:**
- **Habit:**
- **Scope:**

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can login
* User can create a new account
* User can like/unlike an event
* User can leave a comment for an event
* User can view a feed of events
* User can go to purchase ticket page through a button

**Optional Nice-to-have Stories**

* User can post events
* User can search for an event
* User can view events by date in calendar view
* User can follow event organizer
* User can add photos to their comments

### 2. Screen Archetypes

* login screen
   * User can login
   * User can create a new account
* events screen (tableView)
   * User can view a feed of events
   * User can see if they liked the event
   * User can like/unlike an event
* events screen (calendarView)
   * User can view events by date in calendar view
* event detail screen
   * User can view more details for that event
   * User can like/unlike event
   * User can view how many likes for each event
   * User can comment on that event
   * User can see other comments on that event
   * User can click a button to access buy tickets page

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Events list view
* Events Calendar view

**Flow Navigation** (Screen to Screen)

* login screen
   * Home
* events screen (tableView)
   * event detail screen
* events screen (calendarView)
   * event detail screen
* events detail screen
   * none
   

## Wireframes
<img src="https://github.com/EventsNearMe/EventsNearMe/blob/main/wireframes/EventsNearMe.gif" width=300>
<img src="https://github.com/EventsNearMe/EventsNearMe/blob/main/wireframes/hand-sketched-wireframes.jpg" width=300>


## Schema 

### Models

Event

| Property     | Type                 | Description                                                                  |
| --------     | --------             | --------                                                                     |
| name         | multipart-text       | Event name                                                                  |
| event-pictures     | image URL               | Images of the event                                            |
| event-date      | datetime             | Date and time when event will take place                |
| summary      | string               | (Optional) Event summary. Short summary describing the event and its purpose.|
| favorite   | Pointer to favorite-objects                | Favorite objects that link their users and events                                |
| user         | Pointer to User      | User Object                    |
| comment      | Pointer to Comment-objects   | Comment objects that link their users, events and text                                         |

### Networking

* Events Screen (tableView)

   * (Read/GET) Query all events
  
    ```
    let query = PFQuery(className: "Event")
    let today = Date()
    let nyToday = Calendar.current.date(byAdding: .hour, value: -5, to: today)!
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd"
    let date = dateFormatter.string(from: nyToday)
    query.whereKey("Date", greaterThanOrEqualTo: date)
    query.order(byAscending: "Date")
    query.includeKeys(["favorite", "favorite.author"])
    query.findObjectsInBackground{(events,error) in
        if events != nil{
            // TODO: Do something with events...
        }
        else{
            print("unable to load events from bac4App")
            
        }
    }
    ```
    * (Delete) Delete existing like
    * (Create/COMMENT) Create a new comment on an event

* Events Screen (calendarView)
   * (Read/GET) Query all events
   
* Events Detail Screen
   * (Delete) Delete existing like
   * (Create/COMMENT) Create a new comment on an event

### Milestone 10 build progress

### User Stories
- [x] User can sign up, login and logout
- [x] App retains user information after app is closed and re-opened
- [x] User can toggle between the AllEvents Tab and the Calendar Tab

### Walkthrough GIF - Milestone 10

<img src="ezgif.com-gif-maker.gif" width=250><br>

### Milestone 11 build progress

### User Stories
- [x] User can view and scroll through a list of events in the app
- [x] User can view the event posters in each row
- [x] User can tap a cell to see more details about a particular event
- [x] User can tap the ticket button to get ticket information in the browser

### Walkthrough GIF - Milestone 11

<img src="ezgif.com-gif-maker2.gif" width=250><br>

### Milestone 12 build progress

### User Stories
- [x] User can create new comments on a particular event
- [x] Presenting events in a calendar view
- [x] User can tap on a grid in calendar view to see more details about a particular event
- [x] User can click to see the following month events in a calendar view

### Walkthrough GIF - Milestone 12

<img src="ezgif.com-gif-maker3.gif" width=250><br>

### Milestone 13 build progress

### User Stories
- [x] User can reload new events
- [x] User can favorite a tweet
- [x] User can view comments on a post  
- [x] User can add a new comment

### Walkthrough GIF - Milestone 13

<img src="ezgif.com-gif-maker4.gif" width=250><br>
