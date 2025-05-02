package main

import "core:fmt"
import "core:strings"
import os "core:os/os2"

import rl "vendor:raylib"

BACKGROUND_COLOR : rl.Color : {125, 125, 125, 255}
FONT_COLOR : rl.Color : rl.WHITE
FONT_SIZE :: 25

State :: struct {
    posX, posY : i32,
    content: [dynamic]string,
    files: [dynamic]string,
    current_file: string,
    raw_data: []u8
}

state_new :: proc() -> State {
    return {
        0, 0,
        make([dynamic]string, 0, 16),
        make([dynamic]string, 0, 16),
        "",
        {}
    }
}

state_free :: proc(state: ^State) {
    delete(state.content)
    delete(state.files)
    delete(state.raw_data)
}

main :: proc() {
    if len(os.args) < 2 {
        usage()
        os.exit(1)
    }

    state := state_new()
    defer state_free(&state)

    files := os.args[1:]
    for file in files {
        append(&state.files, file)
    }

    state.current_file = os.args[1]

    if os.exists(state.current_file) {
        data, err := os.read_entire_file_from_path(state.current_file, context.allocator)
        if err != nil {
            fmt.panicf("Failed to read {}: {}", state.current_file, err)
        }
        state.raw_data = data
        lines := strings.split_lines(string(data))
        defer delete(lines)

        for line in lines {
            append(&state.content, line)
        }
    }

    rl.InitWindow(800, 600, "Code Editor")
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
        render(&state)
    }
}

render :: proc(state: ^State) {
    rl.BeginDrawing()

    rl.ClearBackground(BACKGROUND_COLOR)
    for line, idx in state.content {
        c_line := strings.clone_to_cstring(line)
        defer delete(c_line)

        rl.DrawText(c_line, 5, i32(5 + (FONT_SIZE * idx)), FONT_SIZE, FONT_COLOR)
    }

    rl.EndDrawing()
}

usage :: proc() {
    assert(len(os.args) >= 1)
    fmt.printfln("Usage: {} [file-names...]", os.args[0])
}
