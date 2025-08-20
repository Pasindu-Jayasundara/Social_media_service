import ballerina/http;
import ballerina/time;
import ballerina/sql;
import ballerinax/mysql;

type User record {|
    readonly int id;
    string name;

    @sql:Column {name: "birth_date"}
    time:Date birthDate;

    @sql:Column {name: "mobile_number"}
    string mobileNumber;
|};

type NewUser record {|
    string name;
    time:Date birthDate;
    string mobileNumber;
|};

type ErrorDetails record {
    string message;
    string details;
    time:Utc timeStamp;
};

type UserNotFound record {|
    *http:NotFound;
    ErrorDetails body;
|};

table<User> key(id) users = table [

    {id: 1, name: "Alice", birthDate: {
        year: 1990,
        month: 1,
        day: 1
    }, mobileNumber: "1234567890"},

    {id: 2, name: "Bob", birthDate: {
        year: 1992,
        month: 2,
        day: 2
    }, mobileNumber: "0987654321"}
];


mysql:Client socialMediaDb = check new ("localhost", "root", "password", "social_media", 3306);

service /social\-media on new http:Listener(port = 9090) {
    resource function get users() returns User[]|error {

        stream<User,sql:Error?> query = socialMediaDb->query(`select * from users`);
        return  from var user in query select user;
        // return users.toArray();
    }

    resource function get users/[int id]() returns User|UserNotFound|error {
        
        // User? user = users[id];
        // if user is () {
        //     UserNotFound userNotFound = {
        //         body: {message: string `id: ${id}`, details: string `users/${id}`, timeStamp: time:utcNow() }  
        //     };

        //     return userNotFound;
        // }

        User|sql:Error user = socialMediaDb->queryRow(`select * from users where id = ${id}`);
        if user is sql:NoRowsError {

            UserNotFound userNotFound = {
                body: {message: string `id: ${id}`, details: string `users/${id}`, timeStamp: time:utcNow() }  
            };

            return userNotFound;
        }

        return user;
    } 

    resource function post users(NewUser newUser) returns http:Created|error {

        // users.add({id: users.length()+1, ...newUser});

        _ = check socialMediaDb->execute(`
            insert into users (name, birthDate, mobileNumber) 
            values (${newUser.name}, ${newUser.birthDate}, ${newUser.mobileNumber})
        `);

        return http:CREATED;
    }
}

