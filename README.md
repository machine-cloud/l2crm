# l2crm
#### (where x = CRM)

This log drain looks for device failures (failure=true) and opens
up a support case in CRM, it reports the error by reading
the error code (code=XX) in the log line.

To set error messages, create an ENV var named `CODE_<N>` where N is the code number.  For example, to create the message for error code 42 set `CODE_42` to your desired message.


## Install

    > npm install
    > foreman start web
    > ./test.sh

## ENV

    CRM_USERNAME
    CRM_PASSWORD


## Special Behavior

For demo purposes, you can set the `CONTACT_ID` to open requests as
that contact.
