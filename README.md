# 🧩 3x3 2048 (RISC-V Assembly)

A simplified 3x3 version of the classic 2048 game implemented in RISC-V assembly.

---

## 🎮 How to Run
- Open the `.asm` file in a RISC-V simulator (e.g., RARS)
- Assemble and run the program
- Follow on-screen prompts

---

## 🕹️ Controls

| Key | Action |

|-----|--------|

| W | Move Up |

| A | Move Left |

| S | Move Down |

| D | Move Right |

| X | Exit Game |

- Invalid inputs are ignored and will be prompted again

---

## 🚀 Game Modes

### 1. New Game
- Starts with an empty 3x3 board
- A `2` tile is randomly placed

### 2. Custom Start State
- Input 9 numbers to define the board
- Values are filled row-wise:

[1] [2] [3]

[4] [5] [6]

[7] [8] [9]


---

## 🧱 Game Rules
- Tiles slide in the chosen direction
- Matching tiles merge (value doubles)
- Only one merge per tile per move
- A new tile appears only if the board changes

---

## 🏆 Win Condition
- Reach a `512` tile

---

## 💀 Lose Condition
- No empty cells AND
- No possible merges

---

## ⚠️ Limitations
- Non-numeric input in custom board setup may be treated as `0`

---

## 👥 Authors
- Dash Cenido  
- Justin Chuah  
- Mateo Cruz  
