import ballerina/http;
import ballerina/time;

type User record {|
    readonly string id;
    string name;
    time:Date birthDate;
    string mobileNumber;
|};

table<User> key(id) users = table [

    {id: "1", name: "Alice", birthDate: {
        year: 1990,
        month: 1,
        day: 1
    }, mobileNumber: "1234567890"},

    {id: "2", name: "Bob", birthDate: {
        year: 1992,
        month: 2,
        day: 2
    }, mobileNumber: "0987654321"}
];

service /social\-media on new http:Listener(port = 9090) {
    resource function get users() returns User[]|error {

        return users.toArray();
    }
}

