
;
; It Might Be NES, Copyright (C) 2001,2002,2003 Allan Blomquist
; All rights reserved.  Email: ablomquist@gmail.com
;
; This file is part of imbNES.
;
; imbNES is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; imbNES is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with imbNES.  If not, see <http://www.gnu.org/licenses/>.
;

palDMAlist		dcb		192, 0	;1 head + 2 for dot of color
sprPalDMAlist		dcb		576, 0	;1 head + 8 for dot of color

bg1DMAlist		dcb		34560, 0	;4 word gpu trans + 1 for mask setting + 3 for semitrans rect to set upper 2 color bits for 32*30 bg tile prims

bg2DMAlist		dcb		34560, 0	;for second NT

spriteDMAlist	dcb		2816, 0	;tex pos, mask setting, 8 spr, 1 header for 64 sprites

afterSprDMAlist	dw	$00FFFFFF		;the buildList sub makes the sprite list link to the
				dw	$E6000000		;word after the last sprite.  that's these 2 words

patTmp dcb $400, 0	;happens to be the right amount of space
