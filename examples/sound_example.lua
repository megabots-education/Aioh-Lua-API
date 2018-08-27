require "sound"

star_wars = {}
star_wars[1]  = {"a", 500}
star_wars[2]  = {"a", 500}
star_wars[3]  = {"a", 500}
star_wars[4]  = {"f", 350}
star_wars[5]  = {"cH", 150}
star_wars[6]  = {"a", 500}
star_wars[7]  = {"f", 350}
star_wars[8]  = {"cH", 150}
star_wars[9]  = {"a", 1000}
star_wars[10] = {"eH", 500}
star_wars[11] = {"eH", 500}
star_wars[12] = {"eH", 500}
star_wars[13] = {"fH", 350}
star_wars[14] = {"cH", 150}
star_wars[15] = {"gS", 500}
star_wars[16] = {"f", 350}
star_wars[17] = {"cH", 150}
star_wars[18] = {"a", 1000}
star_wars[19] = {"aH", 500}
star_wars[20] = {"a", 350}
star_wars[21] = {"a", 150}
star_wars[22] = {"aH", 500}
star_wars[23] = {"gSH", 250}
star_wars[24] = {"gH", 250}
star_wars[25] = {"fSH", 125}
star_wars[26] = {"fH", 125}
star_wars[27] = {"fSH", 250}
star_wars[28] = {"w", 250}
star_wars[29] = {"aS", 250}
star_wars[30] = {"dSH", 500}
star_wars[31] = {"dH", 250}
star_wars[32] = {"cSH", 250}
star_wars[33] = {"cH", 125}
star_wars[34] = {"b", 125}
star_wars[35] = {"cH", 250}
star_wars[36] = {"w", 250}
star_wars[37] = {"f", 125}
star_wars[38] = {"gS", 500}
star_wars[39] = {"f", 375}
star_wars[40] = {"a", 125}
star_wars[41] = {"cH", 500}
star_wars[42] = {"a", 375}
star_wars[43] = {"cH", 125}
star_wars[44] = {"eH", 1000}
star_wars[45] = {"aH", 500}
star_wars[46] = {"a", 350}
star_wars[47] = {"a", 150}
star_wars[48] = {"aH", 500}
star_wars[49] = {"gSH", 250}
star_wars[50] = {"gH", 250}
star_wars[51] = {"fSH", 125}
star_wars[52] = {"fH", 125}
star_wars[53] = {"fSH", 250}
star_wars[54] = {"w", 250}
star_wars[55] = {"aS", 250}
star_wars[56] = {"dSH", 500}
star_wars[57] = {"dH", 250}
star_wars[58] = {"cSH", 250}
star_wars[59] = {"cH", 125}
star_wars[60] = {"b", 125}
star_wars[61] = {"cH", 250}
star_wars[62] = {"w", 250}
star_wars[63] = {"f", 250}
star_wars[64] = {"gS", 500}
star_wars[65] = {"f", 375}
star_wars[66] = {"cH", 125}
star_wars[67] = {"a", 500}
star_wars[68] = {"f", 375}
star_wars[69] = {"c", 125}
star_wars[70] = {"a", 1000}

print("Tocando única nota de forma síncrona")
sound.sPlayNote(5, star_wars[1][1], star_wars[1][2])
tmr.delay(1000000)

print("Tocando música completa do início de forma síncrona")
sound.sPlayMusic(5, star_wars)
tmr.delay(1000000)

print("Tocando música a partir da trigésima nota de forma síncrona")
sound.sPlayMusic(5, star_wars, 30)
tmr.delay(1000000)

print("Tocando música a partir do início de forma asíncrona")
sound.playMusic(5, star_wars, function()
  print("Terminado.")
end)
print("Você pode executar outros comandos enquanto a música é tocada!")
