# T1A3 - GBM (Gundam Breaker Mobile) Helper

## Background information
Gundam Breaker Mobile (GBM) is a Japanese mobile game. Since its release in July 2019, more than 250 mobile suits have been introduced to the game, each with collectable parts such as head, body, arm, leg, backpack, weapon, and shield to allow players to build their customised mobile suits to clear missions.

## Purpose of GBM Helper
Gundam Breaker Mobile provides a large number of collectible parts with different stats, active skills, and passive skills which makes building a good mobile suit a challenging and time-consuming task for its players. The [Dengeki Wiki Japan](https://wiki.dengekionline.com/gbm/) even though has details of all the parts, only offers a sort feature, players will need to go back and forth to view the stats and skills that each part provides. GBM Helper aims to provide assistance to the players of Gundam Breaker Mobile by including:
* a login/sign-up feature to allow users to retrieve their current build and access other features upon successful login
* a view current build feature to allow users to view the parts they are currently using, sum up the value of each attribute and display them in a table
* a reset feature to allow users to start a new build from scratch
* a search feature to allow users to search for a certain part by its name, users then can view the details of the part
* a filter feature to allow users to focus on a certain category (e.g. arm)
* a sort feature to allow users to sort parts by a certain attribute (e.g. melee attack) then display the top 5 parts
* a recommendation feature to recommend parts to users and display how their stats will change by using the recommended parts

Gundam Breaker Mobile now has a Japanese version and a global version which includes language options of English, Chinese, and Korean. GBM Helper will first look to assist users who are playing the English version until the app supports other language options. Users will be able to log into the GBM Helper to view their current build, if there is a part that they know will imporve their build, they can use the search feature to search for the part and update their build. Otherwise, they can take advantage of the filter/sort feature and recommendation feature to find ideas on how to improve their build, and they will be able to overwrite their existing build.

## Installation
If you haven't installed Ruby

[https://www.ruby-lang.org/en/documentation/installation/](https://www.ruby-lang.org/en/documentation/installation/)

To clone the project
```
git clone https://github.com/noe13hsu/T1A3---GBM-Helper.git
```
**Inside your terminal to install the required gems**

if you don't have the bundler gem
```
gem install bundler
bundle install
```
or
```
./install.sh
```
if you have already installed the bundler gem
```
bundle install
```

## Usage
**Inside your terminal to run GBM Helper**

```
ruby app.rb
```
or
```
./execute.sh
```
Please note if you run GBM Helper with ./execute.sh in Windows, it is possible that the arrow keys won't work....

## Screen shots of control flow diagram

**Title menu**

![Title Menu](./docs/title_menu.png)

**MVPs**

![Title Menu](./docs/mvp_1.png)
![Title Menu](./docs/mvp_2.png)

## Implementation plan
* create a control flow diagram by 2 April, high priority
* create a csv file to store user details by 3 April, high priority
* create csv files to store parts information by 3 April, high priority
* create a login/sign-up feature by 3 April, high priority, MVP
* create a reset feature by 4 April, high priority, MVP
* create a update build feature by 5 April, high priority
* create a search feature by 5 April, high priority, MVP
* create a filter/sort feature by 6 April, high priority, MVP
* use the colorize gem to change the text colour of a higher attribute to blue and a lower attribute to red by 7 April, low priority
* create a method to sum up each attribute based on user's current build by 8 April, medium priority, MVP
* create a method to calculate build type based on user's current build by 8 April, medium priority
* create a recommendation feature by 9 April, high priority, MVP
    
    * create a method to display the parts with a higheset attribute of a certain type by 8 April, high priority
    * create a method to filter pilots by a certain job license and display the result by 9 April, high priority
    * create a method to filter parts by a certain word tag and display the result by 9 April, high priority
* create a username/password validation method by 9 April, low priority
* create a method to get job licenses from pilots by 9 April, low priority
* create a method to calculate word tags based on user's current build by 9 April, medium priority
* design a colourful title the app by 10 April, low priority
* create slide deck by 10 April, low priority

Please see [my Trello board](https://trello.com/b/qXOb5Gb3/gbm-helper)


## Referenced sources
* Parts' names in English - [Dengeki Wiki](https://g-b-en.ggame.jp/wiki/)
* Parts' stats and details - [Dengeki Wiki Japan](https://wiki.dengekionline.com/gbm/)

## GitHub link
[https://github.com/noe13hsu/T1A3---GBM-Helper](https://github.com/noe13hsu/T1A3---GBM-Helper)

