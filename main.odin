package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

screenSize  : [2]i32    : {1280, 720}

gridSize    : f32   : 200
hgs         : f32   : gridSize/2
coinRadius  : f32   : 6

Player :: enum {P1, P2}

Coin :: struct {
    curPos  : [2]i32,
    nextPos : [2]i32,
    player  : Player
}

TileStatus :: enum {EMPTY, P1, P2, INVALID}

Tile :: struct {
    selected : bool,
    status   : TileStatus,
}

// helps with testing and loading saved games ?
initTiles :: proc() -> [7][7]Tile {

    inv     : Tile  = {false, .INVALID}
    t1      : Tile  = {false, .P1}
    t2      : Tile  = {false, .P2}
    empty   : Tile  = {false, .EMPTY}

    return {
        {inv,   inv,    t1,     t1,     t1,     inv,    inv},
        {inv,   inv,    t1,     t1,     t1,     inv,    inv},
        {t1,    t1,     t1,     t1,     t2,     t2,     t2},
        {t1,    t1,     t1,     empty,  t2,     t2,     t2},
        {t1,    t1,     t1,     t2,     t2,     t2,     t2},
        {inv,   inv,    t2,     t2,     t2,     inv,    inv},
        {inv,   inv,    t2,     t2,     t2,     inv,    inv},
    }
}

main :: proc() {

    rl.InitWindow(screenSize.x, screenSize.y, "yo I got a window")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    coins := make(map[[2]i32]Coin, 32)
    tiles := initTiles()

    curPlayer := Player.P1

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        defer rl.EndDrawing()


        rl.ClearBackground(rl.RAYWHITE)

        center := [2]f32{f32(screenSize.x)/2, f32(screenSize.y)/2}
        rl.DrawText("Padavettu", 10, 10, 30, rl.GRAY)
        switch curPlayer {
        case .P1:
            rl.DrawText("Player 1's turn", 10, 45, 30, rl.GRAY)
        case .P2:
            rl.DrawText("Player 2's turn", 10, 45, 30, rl.GRAY)
        }
        drawGrid(center)
        drawGrid(center + {-1, 0}*gridSize)
        drawGrid(center + {+1, 0}*gridSize)
        drawGrid(center + {0, -1}*gridSize)
        drawGrid(center + {0, +1}*gridSize)
        tilePos : [2]f32 

        for i in -3..=3 {
            for j in -3..=3 {
                
                tilePos = center + {f32(i), f32(j)}*hgs
                tile := tiles[i+3][j+3]
                radius := coinRadius

                if tile.selected do radius *= 1.5
                switch tile.status {
                case .P1:
                    rl.DrawCircleV(tilePos, radius, rl.RED)
                case .P2:
                    rl.DrawCircleV(tilePos, radius, rl.BLUE)
                case .EMPTY, .INVALID:
                }
            }
        }

        mousePos := rl.GetMousePosition()
        diff := mousePos - center
        ntho := [2]f32{ math.round(diff.x / hgs)*hgs, math.round(diff.y / hgs)*hgs}
        // BUG: this consider all points inside the square
        if ntho.x < 4*hgs && ntho.y < 4*hgs &&
            ntho.x > -4*hgs && ntho.y > -4*hgs {
            rl.DrawCircleLinesV(ntho + center, 10, rl.GREEN)
        }
    }
}

deselectAll :: proc (tiles: ^[7][7]Tile) {
    for i in 0..<7 {
        for j in 0..<7 {
            tiles[i][j].selected = false
        }
    }
}


drawGrid :: proc(c: [2]f32) {
        rl.DrawRectangleLines(
            i32(c.x - hgs), i32(c.y - hgs),
            i32(gridSize), i32(gridSize), rl.BLACK,
        )
        rl.DrawLineV(c + {-1, +1}*hgs, c + {+1, -1}*hgs, rl.BLACK)
        rl.DrawLineV(c + {-1, -1}*hgs, c + {+1, +1}*hgs, rl.BLACK)
        rl.DrawLineV(c + {0, +1}*hgs,  c + {0, -1}*hgs, rl.BLACK)
        rl.DrawLineV(c + {-1, 0}*hgs,  c + {+1, 0}*hgs, rl.BLACK)
}
