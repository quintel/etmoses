etloader
========

Calculation module to compute loads in a multi-level (LV, MV, HV, et cetera) electricity network

### User administration
#### Creating a user

This application uses te monban gem for authorization. In order to sign up a
user, use the following command:

`Monban::Services::SignUp.new({email: <email>, password: <password>}).perform`

#### Activating a user

Find the user by email:

````ruby
user = User.find_by_email("<email>")
````

Call activate:

````ruby
user.activate!
````
