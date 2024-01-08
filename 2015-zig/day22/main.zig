const std = @import("std");
const print = std.debug.print;
const debug = false;

const Player = struct {
    life : isize = 50,
    mana : isize = 500,
    armor : isize = 0,
    countShield   : u8 = 0,
    countPoison   : u8 = 0,
    countRecharge : u8 = 0,
};

const Boss = struct {
    life : isize = 51,
    damage : isize = 9,
};

const Spells = enum {
    Shield,
    Poison,
    Recharge,
    MagicMissile,
    Drain,
};

const SpellsCosts = [_]usize{ 113, 173, 229, 53, 73 };

fn printStatus(p : Player, b : Boss) void {
    print("\n------------\n", .{});
    print("- Player has {} hit points, {} armor, {} mana\n", .{p.life, p.armor, p.mana});
    print("- Boss has {} hit points\n", .{b.life});
}

fn updateEffects(p : *Player, b : *Boss) void {
    if(p.*.countPoison > 0) {
        if(debug) print("Poison deals 3 damage; its timer is now {}\n", .{p.*.countPoison});
        b.*.life -= 3;
        p.*.countPoison -= 1;
        if(p.*.countPoison == 0) {
            if(debug) print("Poison wears off\n", .{});
        }
    }
    if(p.*.countRecharge > 0) {
        if(debug) print("Recharge provides 101 mana; its timer is now {}\n", .{p.*.countRecharge});
        p.*.mana += 101;
        p.*.countRecharge -= 1;
        if(p.*.countRecharge == 0) {
            if(debug) print("Recharge wears off\n", .{});
        }
    }
    if(p.*.countShield > 0) {
        if(debug) print("Shield's timer is now {}\n", .{p.*.countShield});
        p.*.countShield -= 1;
        if(p.*.countShield == 0) {
            p.*.armor = 0;
            if(debug) print("Shield wears off, decreasing armor by 7\n", .{});
        }
    }
}

//returns true if the spell was casted
//without the player dying
fn tryToCast(p : *Player, b : *Boss, spell : Spells) bool {
    switch(spell) {
        .MagicMissile => {
            if(p.*.mana >= SpellsCosts[@intFromEnum(Spells.MagicMissile)]) {
                b.*.life -= 4;
                p.*.mana -= SpellsCosts[@intFromEnum(Spells.MagicMissile)];
                return true;
            }
        },
        .Drain => {
            if(p.*.mana >= SpellsCosts[@intFromEnum(Spells.Drain)]) {
                b.*.life -= 2;
                p.*.life += 2;
                p.*.mana -= SpellsCosts[@intFromEnum(Spells.Drain)];
                return true;
            }
        },
        .Shield => {
            if(p.*.countShield == 0 and p.*.mana >= SpellsCosts[@intFromEnum(Spells.Shield)]) {
                p.*.countShield = 6;
                p.*.armor = 7;
                p.*.mana -= SpellsCosts[@intFromEnum(Spells.Shield)];
                return true;
            }
        },
        .Poison => {
            if(p.*.countPoison == 0 and p.*.mana >= SpellsCosts[@intFromEnum(Spells.Poison)]) {
                p.*.countPoison = 6;
                p.*.mana -= SpellsCosts[@intFromEnum(Spells.Poison)];
                return true;
            }
        },
        .Recharge => {
            if(p.*.countRecharge == 0 and p.*.mana >= SpellsCosts[@intFromEnum(Spells.Recharge)]) {
                p.*.countRecharge = 5;
                p.*.mana -= SpellsCosts[@intFromEnum(Spells.Recharge)];
                return true;
            }
        },
    }
    return false;
}

fn battleRound(player : Player, boss : Boss, minMana : *usize, curMana : usize, hard : bool) void {
    var p = player;
    var b = boss;
    //there is already a better solution
    //the player has lost
    //the player has no mana for any spell
    if(hard) { //for hard mode, second half
        p.life -= 1;
    }
    if(curMana > minMana.* or p.life <= 0 or p.mana < SpellsCosts[0]) {
        return;
    }
    //check efects at the begin of the player turn
    if(debug) printStatus(p, b);
    updateEffects(&p, &b);

    //check for life of the boss
    if(b.life <= 0) {
        if(curMana < minMana.*) {
            minMana.* = curMana;
        }
        return;
    }

    //player turn
    var tmpPlayer = p;
    var tmpBoss = b;
    inline for([_]Spells { Spells.Shield, Spells.Poison, Spells.Drain, Spells.MagicMissile, Spells.Recharge }) |s| {
        tmpPlayer = p;
        tmpBoss = b;
        if(tryToCast(&tmpPlayer, &tmpBoss, s)) {
            if(debug) printStatus(tmpPlayer, tmpBoss);

            updateEffects(&tmpPlayer, &tmpBoss); //at the begin of the boss turn
            if(tmpBoss.life <= 0) { //
                if(curMana + SpellsCosts[@intFromEnum(s)] < minMana.*) {
                    minMana.* = curMana + SpellsCosts[@intFromEnum(s)];
                }
                return;
            }
            tmpPlayer.life -= if(tmpBoss.damage <= tmpPlayer.armor) 1 else tmpBoss.damage - tmpPlayer.armor; //boss turn

            if(debug) print("Boss deals {} damage\n", .{if(tmpBoss.damage <= tmpPlayer.armor) 1 else tmpBoss.damage - tmpPlayer.armor});

            battleRound(tmpPlayer, tmpBoss, minMana, curMana + SpellsCosts[@intFromEnum(s)], hard);
        }
    }
}

pub fn main() !void {

    var minMana : usize = std.math.maxInt(usize);
    battleRound(Player{}, Boss{}, &minMana, 0, false);
    print("Part1: {}\n", .{minMana});
    minMana = std.math.maxInt(usize);
    battleRound(Player{}, Boss{}, &minMana, 0, true);
    print("Part2: {}\n", .{minMana});
}
