const std = @import("std");
const print = std.debug.print;

fn increasePassword(password : []u8) void {
    //used for increasing the char behind the current one
    var increaseNext = false;
    const limit = password.len - 1;
    if(password[limit] == 'z') {
        increaseNext = true;
        for(0..password.len) |i| {
            if(password[limit - i] == 'z' and increaseNext) {
                increaseNext = true;
                password[limit - i] = 'a';
                continue;
            }
            if(increaseNext) {
                password[limit - i] += 1;
                increaseNext = false;
            }
        }
    } else {
        password[limit] += 1;
    }
}

fn findPassword(password : []u8) void {
    outter_loop__ : while(true) {
        var i : usize = 0;
        var eqPair : usize = 0;
        var hasSequence : bool = false;
        inner_loop__ : while(i < password.len) : (i += 1) {
            //if c is 'i', 'o' or 'l' increase the password
            for([_]u8{'i', 'o', 'l'}) |c| {
                if(password[i] == c) {
                    password[i] = c + 1;
                    for(i+1..password.len) |j| {
                        password[j] = 'a';
                    }
                    continue : inner_loop__;
                }
            }

            //check if the char and it's neighbour are equal
            if(i+1 < password.len and password[i] == password[i+1]) {
                eqPair += 1;
                i += 1;
            }
            //check if has a increasing sequence of 3 chars
            if(!hasSequence and i + 2 < password.len
               and password[i] == password[i+1] - 1
               and password[i+1] == password[i+2] - 1)
            {
               hasSequence = true;
            }
        }
        if(eqPair >= 2 and hasSequence) {
            break : outter_loop__;
        } else {
            //continue if the password is not acceptable
            increasePassword(password);
        }
    }
}

pub fn main() !void {
    const input = "hepxcrrq";
    const password = try std.heap.page_allocator.alloc(u8, input.len);
    defer std.heap.page_allocator.free(password);
    @memcpy(password, input);

    findPassword(password);
    print("first answer: {s}\n", .{password});

    increasePassword(password); //find the next one
    findPassword(password);
    print("second answer: {s}\n", .{password});
}
