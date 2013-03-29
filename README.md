# l2crm

This app works as a drain for the logplex stream monitoring it for device failures (failure=true). When failure is detected, a case is opened in Service Cloud using the Force.com REST API. Error code is determeined by reading code=XX in the log line.

To set error messages, create an ENV var named `CODE_<N>` where N is the code number.  For example, to create the message for error code 42 set `CODE_42` to your desired message.


## Install

    > npm install
    > foreman start web
    > ./test.sh

## ENV

    RATE_LIMIT - number of seconds to wait before opening another support case
                 for a given device id / error code
    CRM_USERNAME
    CRM_PASSWORD


## Special Behavior

For demo purposes, you can set the `CONTACT_ID` to open requests as
that contact.
