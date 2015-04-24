# BigMLKitSample App

![alt tag](https://github.com/bigmlcom/BigMLKit/blob/master/BigMLKit.jpg)

BigMLKitSampleApp is a full application for iOS showing how you can
leverage BigMLKit. The app allows you to make predictions based on
any of three source files that are bundled with the app.

BigMLKit brings the ease of “one-click-to-predict” to iOS and OS X developers by making it really easy to interact with BigML’s REST API though a higher-level view of a “task”.

A task is, in its most basic version, a sequence of steps that is carried out through BigML’s API. Each step has traditionally required a certain amount of work such as preparing the data, launching the remote operation, waiting for it to complete, collecting the right data to prepare the next step and so on. BigMLKit takes care of all of this “glue logics” for you in a streamlined manner, while also providing an abstracted way to interact with BigML and build complex tasks on top of our platform.

To get BigMLKitSample together will all of its dependencies, run:

    $ git clone --recurse-submodules https://github.com/bigmlcom/BigMLKitSample.git

You need to have a BigML account in order to use the app. You can
create a free BigML account and use it for development purposes.
Once you have your account ready, please enter your credentials
in the BML4iOS.m file.


# License

BigMLKit is open sourced under the
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
