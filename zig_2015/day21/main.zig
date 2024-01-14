const std = @import("std");
const print = std.debug.print;
const life = 100;

const Monster = struct {
    hitPoints: usize = life,
    damage: usize = 8,
    armor: usize = 2,
};

const Pair = struct {
    f: usize,
    s: usize,
};

const Weapons = [5]Pair{
    Pair{.f = 8, .s = 4},
    Pair{.f = 10, .s = 5},
    Pair{.f = 25, .s = 6},
    Pair{.f = 40, .s = 7},
    Pair{.f = 74, .s = 8},
};

const Armors = [6]Pair{
    Pair{.f = 0, .s = 0},
    Pair{.f = 13, .s = 1},
    Pair{.f = 31, .s = 2},
    Pair{.f = 53, .s = 3},
    Pair{.f = 75, .s = 4},
    Pair{.f = 102, .s = 5},
};

const propertyChange = 4;
const Rings = [7]Pair{
    //without rings
    Pair{.f = 0, .s = 0},
    //from here the rings are for damage
    Pair{.f = 25, .s = 1},
    Pair{.f = 50, .s = 2},
    Pair{.f = 100, .s = 3},
    //from here the rings are for armor
    Pair{.f = 20, .s = 1},
    Pair{.f = 40, .s = 2},
    Pair{.f = 80, .s = 3},
};

pub fn main() !void {
    var turnsToKillMonster : usize = 0;
    var turnsToDie : usize = 0;
    var moneySpent : usize = std.math.maxInt(usize);
    var mostMoneySpent : usize = 0;
    const m = Monster{};
    var curDamage : usize = 0;
    var curArmor : usize = 0;
    for(Weapons) |w| {
        for(Armors) |a| {
            for(Rings, 0..) |r1, i| {
                for(Rings, 0..) |r2, j| {
                    if(j != 0 and i == j) {
                        continue;
                    }
                    curDamage = w.s +
                        (if(i < propertyChange) r1.s else 0) +
                        (if(j < propertyChange) r2.s else 0);
                    curArmor = a.s +
                        (if(i < propertyChange) 0 else r1.s) +
                        (if(j < propertyChange) 0 else r2.s);
                    // print("curDamage: {}, curArmor: {}, curMoneySpent: {}\n", .{curDamage, curArmor, curMoneySpent});
                    // print("bought items: {any}, {any}, {any}, {any}\n", .{w, a, r1, r2});
                    const damageToMonster = if(curDamage <= m.armor) 1 else curDamage - m.armor;
                    turnsToKillMonster = m.hitPoints / damageToMonster;
                    if(m.hitPoints % damageToMonster != 0) turnsToKillMonster += 1;

                    const damageFromMonster = if(m.damage <= curArmor) 1 else m.damage - curArmor;
                    turnsToDie = life / damageFromMonster;
                    if(life % m.damage != 0) turnsToDie += 1;

                    if(turnsToKillMonster <= turnsToDie) {
                        moneySpent = @min(moneySpent, w.f + a.f + r1.f + r2.f);
                    } else {
                        mostMoneySpent = @max(mostMoneySpent, w.f + a.f + r1.f + r2.f);
                    }
                }
            }
        }
    }
    print("moneySpent: {}\n", .{moneySpent});
    print("mostMoneySpent: {}\n", .{mostMoneySpent});
}
