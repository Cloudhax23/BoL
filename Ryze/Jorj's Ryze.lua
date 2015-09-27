--[[
  Jorj's Ryze (v0.21)

  Changelog:
    v0.21 - Improved Desperate Power (R) logic and basic attack prevention
    v0.1 - Initial release
]]
load(Base64Decode("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0QBlQAAACkAAowYAwwBBwBEAHUAAAQYA0gAbAAAAFwABgAZA0gBBgBIAgcASAOWAAAAdQAACHwCAAEwAAAAECwAAAGFkZFN1Yk1lbnUABAcAAABDb21iYXQABAcAAABjb21iYXQABAcAAABWaXN1YWwABAcAAAB2aXN1YWwABAMAAABfRwAEDgAAAFJlYm9ybl9Mb2FkZWQABAkAAABhZGRQYXJhbQAEBwAAAGhvdGtleQAEBwAAAEhvdGtleQAEEgAAAFNDUklQVF9QQVJBTV9JTkZPAAQGAAAAU0FDOlIABAoAAABQcmludENoYXQABFAAAAA8Zm9udCBjb2xvcj0iIzFFOTBGRiI+PGI+W1J5emVdPC9iPiA8Zm9udCBjb2xvcj0iI0VFRUVFRSI+U0FDOlIgRGV0ZWN0ZWQ8L2ZvbnQ+AAQHAAAAYWN0aXZlAAQXAAAAU0NSSVBUX1BBUkFNX09OS0VZRE9XTgAEBwAAAHN0cmluZwAEBQAAAGJ5dGUABAIAAABBAAQBAAAAAAQFAAAAdXNlUQAEEgAAAE92ZXJsb2FkIChRKSBQb2tlAAQTAAAAU0NSSVBUX1BBUkFNX09OT0ZGAAQKAAAAaGl0Q2hhbmNlAAQOAAAALT4gSGl0IENoYW5jZQAEEwAAAFNDUklQVF9QQVJBTV9TTElDRQADAAAAAAAA0D8DAAAAAAAAAAADAAAAAAAA8D8DAAAAAAAAAEAEBwAAAHVzZVFXRQAEFgAAAFNwZWxsIFJvdGF0aW9uIChRV0VSKQAEBQAAAHVzZVIABBsAAAAtPiBVc2UgRGVzcGVyYXRlIFBvd2VyIChSKQAECwAAAGh1bWFuRGVsYXkABBMAAAAtPiBIdW1hbml6ZXIgRGVsYXkABAsAAABvcmRlckJsb2NrAAQWAAAAUHJldmVudCBCYXNpYyBBdHRhY2tzAAQUAAAAUHJlZGljdGlvbkxpYnJhcmllcwAECgAAAEZpbGVFeGlzdAAECQAAAExJQl9QQVRIAAQQAAAASFByZWRpY3Rpb24ubHVhAAQMAAAASFByZWRpY3Rpb24ABBAAAABWUHJlZGljdGlvbi5sdWEABAwAAABWUHJlZGljdGlvbgAEDwAAAEluaXRQcmVkaWN0aW9uAAQLAAAAcHJlZGljdGlvbgAECwAAAFByZWRpY3Rpb24ABBIAAABTQ1JJUFRfUEFSQU1fTElTVAAEDAAAAHNldENhbGxiYWNrAAQGAAAAZHJhd1EABA0AAABEcmF3IFEgcmFuZ2UABAcAAABjb2xvclEABAkAAAAtPiBDb2xvcgAEEwAAAFNDUklQVF9QQVJBTV9DT0xPUgADAAAAAADAX0ADAAAAAAAAPkADAAAAAAAAYkADAAAAAADgb0AEBwAAAGRyYXdXRQAEDwAAAERyYXcgVy9FIHJhbmdlAAQIAAAAY29sb3JXRQADAAAAAADgZ0AECwAAAGRyYXdUYXJnZXQABAwAAABEcmF3IFRhcmdldAAEDAAAAGNvbG9yVGFyZ2V0AAQSAAAAQ3VycmVudCB2ZXJzaW9uOiAABAkAAAB0b3N0cmluZwAEEAAAAF9TQ1JJUFRfVkVSU0lPTgAEBwAAAG15SGVybwAEBwAAAEF0dGFjawAESQAAADxmb250IGNvbG9yPSIjMUU5MEZGIj48Yj5bUnl6ZV08L2I+IDxmb250IGNvbG9yPSIjRUVFRUVFIj5Mb2FkZWQhPC9mb250PgAEDQAAAF9BVVRPX1VQREFURQAEEgAAAEdldEFzeW5jV2ViUmVzdWx0AAQPAAAAcmF3LmdpdGh1Yi5jb20ABCUAAAAvTGVhZ3Vlb2ZMdWEvQm9ML21hc3Rlci9SeXplL3ZlcnNpb24AAwAAAC8AAAAvAAAAAQAEDAAAAEYAQACGQEAAhwAAAV1AAAFGwEAAhkBAAMYAwQCHwAABR4CAAF2AgAAIQACBHwCAAAUAAAAECAAAAHJlcXVpcmUABBQAAABQcmVkaWN0aW9uTGlicmFyaWVzAAQFAAAAUHJlZAAEAwAAAF9HAAQLAAAAcHJlZGljdGlvbgAAAAAAAgAAAAABAAAQAAAASm9yaidzIFJ5emUubHVhAAwAAAAvAAAALwAAAC8AAAAvAAAALwAAAC8AAAAvAAAALwAAAC8AAAAvAAAALwAAAC8AAAABAAAAAgAAAGkAAAAAAAwAAAACAAAABQAAAF9FTlYABwAAAENvbmZpZwBAAAAAWQAAAAIACXQAAACGAEAAh0BAAZsAAAAXQBqAh4DAAMeAQAAYwAABF0AZgIYAQACHwEABm0AAABeAA4CGAMEAh0BBAZsAAAAXQBeAhgDBAIdAQQGHgEEBmwAAABcAFoCGAMEAh0BBAYeAQQGHQEEBmwAAABeAFICGwMEAhwBCAcdAwgAHQUIAzgCBAdKAwgEHwcIAR8FCAA5BAQISgUICzQCBAZ2AAAHMAEMARkHDAN2AgAEFAQABGACBARfAAYDMgEMARsHDAEdBwgKGwcMAh8FCA94AAALfAAAAFwAOgMwAQwBGQcMA3YCAAQUBgAEYAIEBF4AMgMYAxADHQMQBBgHEAAyBRAKGQcMAHYGAAQfBRAIPAUUCDUFFAhnAAAIXwAmAzIBEAEZBwwDdgIABx4DFAQHBBQBFAQACTQHGAlBBgYyQQQGMxQGAAs2BxgOPwQEDkIEBjMfBRgDPwQEDEMEBjEcBxwBPAYECTUEBARlAgY4XgASARwFHAIcBxwAZQAEDF4ADgEcBRwCHAccAToGBAo0BgQFPgYECjkFHARmAgQIXgAGATIFDAMbBwwDHQcIDBsLDAAfCQgReAQACXwEAAIUAAAPAAAAAAAGAAJ4AgAGfAAAAHwCAAB4AAAAEBwAAAGNvbWJhdAAECwAAAG9yZGVyQmxvY2sABAUAAAB0eXBlAAQHAAAAYWN0aXZlAAQDAAAAX0cABAoAAABBdXRvQ2FycnkABAUAAABLZXlzAAQFAAAAbWF0aAAEBQAAAHNxcnQABAIAAAB4AAMAAAAAAAAAQAQCAAAAegAEDAAAAENhblVzZVNwZWxsAAQDAAAAX1cABAcAAABNb3ZlVG8ABAkAAABtb3VzZVBvcwAEBwAAAG15SGVybwAEBQAAAG1hbmEABA0AAABHZXRTcGVsbERhdGEABAYAAABsZXZlbAADAAAAAAAAJEADAAAAAAAASUAECgAAAGN1cnJlbnRDZAADAAAAAAAAAAADAAAAAAAA8D8DAAAAAAAA5D8DMzMzMzMz0z8EDAAAAGF0dGFja1NwZWVkAAQDAAAAbXMAAwAAAAAAwIJAAAAAAAcAAAAAAAABAAIAAwAEAAUABhAAAABKb3JqJ3MgUnl6ZS5sdWEAdAAAAEEAAABBAAAAQQAAAEEAAABBAAAAQQAAAEEAAABBAAAAQgAAAEIAAABCAAAAQgAAAEIAAABCAAAAQgAAAEIAAABCAAAAQgAAAEIAAABCAAAAQgAAAEIAAABCAAAAQgAAAEIAAABCAAAAQgAAAEMAAABDAAAAQwAAAEMAAABDAAAAQwAAAEMAAABDAAAAQwAAAEMAAABDAAAAQwAAAEUAAABFAAAARQAAAEUAAABFAAAARQAAAEYAAABGAAAARgAAAEYAAABGAAAARgAAAEYAAABGAAAARwAAAEcAAABHAAAARwAAAEcAAABHAAAARwAAAEcAAABHAAAARwAAAEcAAABHAAAARwAAAEcAAABHAAAARwAAAEcAAABIAAAASAAAAEgAAABIAAAASQAAAEwAAABMAAAATAAAAE0AAABNAAAATQAAAE0AAABNAAAATgAAAE4AAABOAAAAUQAAAFEAAABRAAAAUQAAAFEAAABRAAAAUQAAAFEAAABRAAAAUQAAAFEAAABRAAAAUQAAAFEAAABRAAAAUQAAAFEAAABSAAAAUgAAAFIAAABSAAAAUgAAAFIAAABSAAAAWAAAAFgAAABYAAAAWAAAAFgAAABZAAAABwAAAAUAAABzZWxmAAAAAAB0AAAABQAAAHVuaXQAAAAAAHQAAAAJAAAAZGlzdGFuY2UAJwAAAG4AAAAJAAAAY29vbGRvd24ASgAAAG4AAAALAAAAd2luZFVwVGltZQBLAAAAbgAAABAAAABiYXNlQXR0YWNrU3BlZWQATgAAAFYAAAAQAAAAYmFzZUF0dGFja0RlbGF5AFMAAABWAAAABwAAAAcAAABDb25maWcABQAAAF9FTlYABgAAAFJFQURZAAkAAABDT09MRE9XTgAZAAAAQXR0YWNrRGVsYXlPZmZzZXRQZXJjZW50AB0AAABBdHRhY2tEZWxheUNhc3RPZmZzZXRQZXJjZW50ABEAAABJc3N1ZUF0dGFja09yZGVyAGAAAABnAAAAAQAGEQAAAEYAQACAAAAAXYAAAYZAQAAZQAABF0ACgIaAQADBwAAAAAGAAEEBAQDWQIEBnUAAAYZAQQDGgEEAAcEBAJ1AgAEfAIAACAAAAAQJAAAAdG9udW1iZXIABBAAAABfU0NSSVBUX1ZFUlNJT04ABAoAAABQcmludENoYXQABEYAAAA8Zm9udCBjb2xvcj0iIzFFOTBGRiI+PGI+W1J5emVdPC9iPiA8Zm9udCBjb2xvcj0iI0VFRUVFRSI+PGk+VmVyc2lvbiAABD8AAAAgaXMgYXZhaWxhYmxlLiBQbGVhc2Ugd2FpdCB3aGlsZSBpdCBpcyBkb3dubG9hZGluZy48L2k+PC9mb250PgAEDAAAAERlbGF5QWN0aW9uAAQPAAAARG93bmxvYWRVcGRhdGUAAwAAAAAAAAAAAAAAAAEAAAAAARAAAABKb3JqJ3MgUnl6ZS5sdWEAEQAAAGEAAABhAAAAYQAAAGMAAABjAAAAYwAAAGQAAABkAAAAZAAAAGQAAABkAAAAZAAAAGUAAABlAAAAZQAAAGUAAABnAAAAAgAAAAcAAAByZXN1bHQAAAAAABEAAAAHAAAAbGF0ZXN0AAMAAAARAAAAAQAAAAUAAABfRU5WAAcAAAABAAAAAQkBCwENAQwBBRAAAABKb3JqJ3MgUnl6ZS5sdWEA8wAAABkAAAAZAAAAGQAAABkAAAAZAAAAGgAAABoAAAAaAAAAGgAAABoAAAAcAAAAHAAAABwAAAAcAAAAHQAAAB0AAAAdAAAAHQAAAB0AAAAdAAAAHQAAAB4AAAAeAAAAHgAAAB4AAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACMAAAAjAAAAIwAAACMAAAAjAAAAIwAAACMAAAAkAAAAJAAAACQAAAAkAAAAJAAAACQAAAAkAAAAJQAAACUAAAAlAAAAJQAAACUAAAAlAAAAJQAAACUAAAAlAAAAJQAAACYAAAAmAAAAJgAAACYAAAAmAAAAJgAAACYAAAAnAAAAJwAAACcAAAAnAAAAJwAAACcAAAAnAAAAKAAAACgAAAAoAAAAKAAAACgAAAAoAAAAKAAAACkAAAApAAAAKQAAACkAAAApAAAAKQAAACkAAAApAAAAKQAAACkAAAAqAAAAKgAAACoAAAAqAAAAKgAAACoAAAAqAAAAKwAAACsAAAArAAAAKwAAACsAAAArAAAAKwAAAC4AAAAuAAAALgAAAC4AAAAuAAAALgAAAC4AAAAuAAAALgAAAC4AAAAuAAAALgAAAC4AAAAuAAAALgAAAC4AAAAuAAAALgAAAC4AAAAuAAAALgAAAC4AAAAuAAAALgAAAC4AAAAvAAAALwAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMQAAADEAAAAxAAAAMQAAADEAAAAyAAAAMgAAADIAAAA0AAAANAAAADQAAAA0AAAANAAAADQAAAA0AAAANQAAADUAAAA1AAAANQAAADUAAAA1AAAANQAAADUAAAA1AAAANQAAADUAAAA1AAAANgAAADYAAAA2AAAANgAAADYAAAA2AAAANgAAADcAAAA3AAAANwAAADcAAAA3AAAANwAAADcAAAA4AAAAOAAAADgAAAA4AAAAOAAAADgAAAA4AAAAOAAAADgAAAA4AAAAOAAAADgAAAA5AAAAOQAAADkAAAA5AAAAOQAAADkAAAA5AAAAOgAAADoAAAA6AAAAOgAAADoAAAA6AAAAOgAAADsAAAA7AAAAOwAAADsAAAA7AAAAOwAAADsAAAA7AAAAOwAAADsAAAA7AAAAOwAAAD0AAAA9AAAAPQAAAD0AAAA9AAAAPQAAAD0AAAA9AAAAPQAAAEAAAABZAAAAWQAAAFsAAABbAAAAWwAAAF4AAABeAAAAXgAAAF8AAABfAAAAXwAAAGcAAABfAAAAagAAAAAAAAAHAAAABwAAAENvbmZpZwAFAAAAX0VOVgAGAAAAUkVBRFkACQAAAENPT0xET1dOABkAAABBdHRhY2tEZWxheU9mZnNldFBlcmNlbnQAHQAAAEF0dGFja0RlbGF5Q2FzdE9mZnNldFBlcmNlbnQAEQAAAElzc3VlQXR0YWNrT3JkZXIAbAAAAHUAAAAAAAQGAAAABgBAAEFAAACBgAAA5QAAAB1AAAIfAIAAAwAAAAQSAAAAR2V0QXN5bmNXZWJSZXN1bHQABA8AAAByYXcuZ2l0aHViLmNvbQAELQAAAC9MZWFndWVvZkx1YS9Cb0wvbWFzdGVyL1J5emUvSm9yaidzIFJ5emUubHVhAAEAAABuAAAAcwAAAAEABQ4AAABGAEAAR0DAAIaAQADBwAAAXYCAAYwAwQAAAQAAnUCAAYxAwQCdQAABhoBBAMHAAQCdQAABHwCAAAgAAAAEAwAAAGlvAAQFAAAAb3BlbgAECwAAAF9GSUxFX1BBVEgABAIAAAB3AAQGAAAAd3JpdGUABAYAAABjbG9zZQAECgAAAFByaW50Q2hhdAAEdwAAADxmb250IGNvbG9yPSIjMUU5MEZGIj48Yj5bUnl6ZV08L2I+IDxmb250IGNvbG9yPSIjRUVFRUVFIj48aT5VcGRhdGUgZmluaXNoZWQgZG93bmxvYWRpbmcuIFBsZWFzZSBwcmVzcyBGOXgyPC9pPjwvZm9udD4AAAAAAAEAAAAAABAAAABKb3JqJ3MgUnl6ZS5sdWEADgAAAG8AAABvAAAAbwAAAG8AAABvAAAAcAAAAHAAAABwAAAAcQAAAHEAAAByAAAAcgAAAHIAAABzAAAAAgAAAAcAAAByZXN1bHQAAAAAAA4AAAAFAAAAZmlsZQAFAAAADgAAAAEAAAAFAAAAX0VOVgABAAAAAAAQAAAASm9yaidzIFJ5emUubHVhAAYAAABtAAAAbQAAAG0AAABzAAAAbQAAAHUAAAAAAAAAAQAAAAUAAABfRU5WAHcAAACQAAAAAAAQbwAAAAYAQABHQEAAWwAAABdABIBGgMAATMDAAMYAwQBdgIABhQAAAViAgAAXgAKARkDBAIaAwACHgEEBwcABAAYBwgBGQcIAR4HCAofBQgBdAQABHQEAAF1AAABHAEMAWwAAABcABoBGgMAATMDAAMZAwwBdgIABhQAAARiAgAAXgAGARoDAAEzAwADGgMMAXYCAAYUAAAFYgIAAF4ACgEZAwQCGgMAAh4BBAcHAAwAGAcIARkHCAEeBwgKHAUQAXQEAAR0BAABdQAAAR0BEAFsAAAAXAA6ARoDEAIHABABdgAABWwAAABfADICHAMUAmwAAABcADICLAAAAxkDFAN2AgAAFAYABzgCBAQ3BAItNwYCLgYEFACEBB4AGAsYARkLGAIeCxgDHwsYABgPHAAdDRwZAA4ADHYMAAc8CgwWNwgIFx4LHAAfDxwBHw8YAhgPHAIcDSAfAA4ADnYMAAU+DgwYNQwMGXQIAAh2CAABGQsIAR0LIBIACAAHGgsgAB4NGBEeDRwTdAoABXUIAACBB+H8GwcgAQAEAAYEBCQDGAcIABkLCAAeCQgRHQkkAHQIAAd0BAAAdQQAAHwCAACYAAAAEBwAAAHZpc3VhbAAEBgAAAGRyYXdRAAQHAAAAbXlIZXJvAAQMAAAAQ2FuVXNlU3BlbGwABAMAAABfUQAECwAAAERyYXdDaXJjbGUABAQAAABwb3MAAwAAAAAAIIxABAUAAABBUkdCAAQGAAAAdGFibGUABAcAAAB1bnBhY2sABAcAAABjb2xvclEABAcAAABkcmF3V0UABAMAAABfVwAEAwAAAF9FAAMAAAAAAMCCQAQIAAAAY29sb3JXRQAECwAAAGRyYXdUYXJnZXQABAoAAABHZXRUYXJnZXQAAwAAAAAAQI9ABAYAAAB2YWxpZAAEDQAAAEdldEdhbWVUaW1lcgADN45Yi0/BAEADxebj2lDBIEAEDgAAAFdvcmxkVG9TY3JlZW4ABAwAAABEM0RYVkVDVE9SMwAEAgAAAHgABA8AAABib3VuZGluZ1JhZGl1cwAEBQAAAG1hdGgABAQAAABjb3MABAIAAAB5AAQCAAAAegAEBAAAAHNpbgAEBwAAAGluc2VydAAEDAAAAEQzRFhWRUNUT1IyAAQLAAAARHJhd0xpbmVzMgADAAAAAAAA8D8EDAAAAGNvbG9yVGFyZ2V0AAAAAAAEAAAAAQAAAAEKAQYQAAAASm9yaidzIFJ5emUubHVhAG8AAAB4AAAAegAAAHoAAAB6AAAAegAAAHoAAAB6AAAAegAAAHoAAAB6AAAAegAAAHsAAAB7AAAAewAAAHsAAAB7AAAAewAAAHsAAAB7AAAAewAAAHsAAAB7AAAAfgAAAH4AAAB+AAAAfgAAAH4AAAB+AAAAfgAAAH4AAAB+AAAAfgAAAH4AAAB+AAAAfgAAAH4AAAB+AAAAfgAAAH4AAAB/AAAAfwAAAH8AAAB/AAAAfwAAAH8AAAB/AAAAfwAAAH8AAAB/AAAAfwAAAIIAAACCAAAAggAAAIMAAACDAAAAgwAAAIUAAACFAAAAhQAAAIUAAACFAAAAhgAAAIYAAACGAAAAhgAAAIYAAACIAAAAiAAAAIgAAACIAAAAiQAAAIkAAACJAAAAiQAAAIkAAACJAAAAiQAAAIkAAACJAAAAiQAAAIkAAACJAAAAiQAAAIkAAACJAAAAiQAAAIkAAACJAAAAiQAAAIkAAACJAAAAigAAAIoAAACKAAAAigAAAIoAAACKAAAAigAAAIoAAACIAAAAjQAAAI0AAACNAAAAjQAAAI0AAACNAAAAjQAAAI0AAACNAAAAjQAAAJAAAAAJAAAABwAAAENvbmZpZwABAAAAbwAAAAcAAAB0YXJnZXQAOAAAAG4AAAAHAAAAcG9pbnRzAEIAAABuAAAABwAAAG9mZnNldABCAAAAbgAAAAwAAAAoZm9yIGluZGV4KQBFAAAAZAAAAAwAAAAoZm9yIGxpbWl0KQBFAAAAZAAAAAsAAAAoZm9yIHN0ZXApAEUAAABkAAAABgAAAHRoZXRhAEYAAABjAAAAAgAAAGMAWwAAAGMAAAAEAAAABwAAAENvbmZpZwAFAAAAX0VOVgALAAAATk9UTEVBUk5FRAAKAAAAc3RhcnRUaW1lAJIAAACgAAAAAAACFgAAAAYAQAAHQEAAGwAAABeAAoAGAEAAB0BAAAeAQAAbAAAAF8ACgEdAQABbAAAAFwACgEbAQABdQIAAF0ABgAYAwQAHQEEAGwAAABdAAIAGwEAAHUCAAB8AgAAGAAAABAMAAABfRwAECgAAAEF1dG9DYXJyeQAEBQAAAEtleXMABAkAAABPbkNvbWJhdAAEBwAAAGNvbWJhdAAEBwAAAGFjdGl2ZQAAAAAAAgAAAAAAAQAQAAAASm9yaidzIFJ5emUubHVhABYAAACTAAAAkwAAAJMAAACTAAAAlAAAAJQAAACUAAAAlgAAAJYAAACXAAAAlwAAAJcAAACYAAAAmAAAAJoAAACcAAAAnAAAAJwAAACcAAAAnQAAAJ0AAACgAAAAAQAAAAUAAABrZXlzAAcAAAAOAAAAAgAAAAUAAABfRU5WAAcAAABDb25maWcAogAAAPEAAAAAABRFAQAABgBAAEZAwABdgIAAhQAAAU6AgACHgEAAGUAAARfAToBHwEAAWwAAABeADYBGAMEATEDBAMaAwQBdgIABhQCAARiAgAAXwAuARsDBAIEAAgDDAIAAAwGAAF2AAAJbAAAAFwAKgIdAwgCbAAAAF0AJgIaAwgDAAIAAncAAAZsAAAAXAAiAB8FCABnAAAIXQAeABgHDAEYBwQCAAQABwUEDAB3BAAJbAQAAF0ADgIUBAAKbAQAAF8AEgIeBwwDHgcMCjsEBA5LBQwPHAcQABwLEAs4BggPSwcMDjcEBAxlARAMXAAKAhkHAAJ2BgACJAQABhoHEAMaBwQAHgkMBRwJEAZ4BAAKfAQAAR8BEAFsAAAAXgD+ARsDBAIEABQDDAAAAAwEAAF2AAAJbAAAAF8A9gIdAwgCbAAAAFwA9gIYAwQCMQEEBBkHFAJ2AgAHFAIABGMAAARdACYCHgMUAh8BFAceAxQDHAMYBB4HDAUYBwQBHgcMCDkEBAhLBQwJHAcQBhgHBAIcBRANOgYECUsHDAg1BAQIZAAGKFwAFgEeBQwGGAcEAh4FDA06BgQJSwcMChwFEAcYBwQDHAcQDjsEBA5LBQwNNgYECGQCBAhfAAYBGQcAAXYGAAEkBAAFGgcQAhkHFAMABgABeAYABXwEAAIYAwQCMQEEBBoHBAJ2AgAHFAIABGMAAARdACoCGgMIAwACAAJ3AAAGbAAAAFwAJgBnAgIwXgAiABoHGAEABAAEdgQABG0EAABdAB4AGAcMARgHBAIABAAHBQQMAHcEAAlsBAAAXQAOAhQEAApsBAAAXwASAh4HDAMeBwwKOwQEDksFDA8cBxAAHAsQCzgGCA9LBwwONwQEDGUBEAxcAAoCGQcAAnYGAAIkBAAGGgcQAxoHBAAeCQwFHAkQBngEAAp8BAACGAMEAjEBBAQbBxgCdgIABxQCAARjAAAEXAAOAhoDGAMcAxwCdgAABm0AAABfAAYCGQMAAnYCAAIkAAAGGgMQAxsDGAAABgACeAIABnwAAAIYAwQCMQEEBBkHFAJ2AgAHFAIABGMAAARfAAYCGQMAAnYCAAIkAAAGGgMQAxkDFAAABgACeAIABnwAAAIdARwCbAAAAFwAcgIYAwQCMQEEBBoHHAJ2AgAHFAIABGMAAARdAGoCGAMEAjEBBAQaBwQCdgIABxQCAAhjAAAEXgBiAhQAAAxmAgI8XwBeAhgDBAIwASAEGgcEAnYCAAYdASAHGAMEAzADIAUZBxQDdgIABx0DIAQYBwQAMAUgChsHGAB2BgAEHQUgCQYEIAI/ByAGNQUMDz8FIAs1BwwMGAsEABwJJBE2CgQJNwoEET8LDBBkAggQXABGABkLJAEaCyQBdAoAAHQIBABdAD4BPg4CTTQPKBo/DgJSNg0oHTYODBo8DgZWNA0sHTYODBoYDwQCHQ0sHj4NLB8YDwQDHQ8sHz8PLB43DAwfGA8EAx0PLB88DzAeNwwMHxgPBAMdDzAcPhACZDcRMCM8DhAcGBMEAB0RMCA8ETQjNA4QHBgTBAAdETAgPRE0IzQOEBwYEwQAMhE0IgAQABs2EgwbNxIMJHYQAAkfETQZbBAAAFwAFgEcETgZbRAAAF0AEgEeEwwCHhEMGToSECFLEwwiHBMQAxwREBo7EBAmSxEMJTYSECBlAxAgXgAGAR0ROBhlABAgXwACARoTEAIaExwBdRAABF0AAgCKCAACjwu9/HwCAADoAAAAEBwAAAGNvbWJhdAAEDQAAAEdldEdhbWVUaW1lcgAECwAAAGh1bWFuRGVsYXkABAUAAAB1c2VRAAQHAAAAbXlIZXJvAAQMAAAAQ2FuVXNlU3BlbGwABAMAAABfUQAECgAAAEdldFRhcmdldAADAAAAAAAgjEAEBgAAAHZhbGlkAAQOAAAAR2V0UHJlZGljdGlvbgAECgAAAGhpdENoYW5jZQAEDQAAAEdldENvbGxpc2lvbgADAAAAAAAASUAEAgAAAHgAAwAAAAAAAABABAIAAAB6AAMAAAAAILgIQQQKAAAAQ2FzdFNwZWxsAAQHAAAAdXNlUVdFAAMAAAAAAMCCQAQDAAAAX1cABAUAAABwYXRoAAQKAAAAc3RhcnRQYXRoAAQIAAAAZW5kUGF0aAADAAAAAAAAAAAEFwAAAENoZWNrV2luZFdhbGxDb2xsaXNpb24ABAMAAABfRQAEBAAAAHBvcwAEBQAAAHVzZVIABAMAAABfUgADAAAAAAAACEAEDQAAAEdldFNwZWxsRGF0YQAEBgAAAGxldmVsAAMAAAAAAABEQAMAAAAAAAAkQAQFAAAAbWFuYQAEBgAAAHBhaXJzAAQPAAAAR2V0RW5lbXlIZXJvZXMAAwAAAAAAgEFAAwAAAAAAADlAAwAAAAAAADRAAwAAAAAAAE5AAwAAAAAAADBAAwAAAAAAAEFABAMAAABhcAADmpmZmZmZ4T8DmpmZmZmZ2T8DMzMzMzMz0z8ECAAAAG1heE1hbmEAA3sUrkfhenQ/A7gehetRuI4/A5qZmZmZmZk/A3sUrkfhepQ/BBAAAABDYWxjTWFnaWNEYW1hZ2UABAgAAAB2aXNpYmxlAAQFAAAAZGVhZAAEBwAAAGhlYWx0aAAAAAAABwAAAAEAAAABBwEJAQMBCwEBEAAAAEpvcmoncyBSeXplLmx1YQBFAQAAowAAAKUAAAClAAAApQAAAKUAAAClAAAApQAAAKUAAACmAAAApgAAAKYAAACmAAAApgAAAKYAAACmAAAApgAAAKYAAACmAAAApwAAAKcAAACnAAAApwAAAKcAAACpAAAAqQAAAKkAAACpAAAAqQAAAKoAAACqAAAAqgAAAKwAAACsAAAArAAAAKwAAACsAAAArQAAAK0AAACtAAAArQAAAK0AAACvAAAArwAAAK8AAACvAAAArwAAAK8AAACvAAAArwAAAK8AAACvAAAArwAAAK8AAACvAAAArwAAAK8AAACvAAAAsAAAALAAAACwAAAAsQAAALEAAACxAAAAsQAAALEAAACxAAAAtwAAALcAAAC3AAAAuAAAALgAAAC4AAAAuAAAALgAAAC6AAAAugAAALoAAAC6AAAAugAAALsAAAC7AAAAuwAAALsAAAC7AAAAuwAAALsAAAC8AAAAvAAAALwAAAC8AAAAvQAAAL0AAAC9AAAAvQAAAL0AAAC9AAAAvQAAAL0AAAC9AAAAvQAAAL0AAAC/AAAAvwAAAL8AAAC/AAAAvwAAAL8AAAC/AAAAvwAAAL8AAAC/AAAAvwAAAL8AAAC/AAAAvwAAAL8AAADAAAAAwAAAAMAAAADBAAAAwQAAAMEAAADBAAAAwQAAAMUAAADFAAAAxQAAAMUAAADFAAAAxQAAAMUAAADGAAAAxgAAAMYAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADJAAAAyQAAAMkAAADJAAAAyQAAAMsAAADLAAAAywAAAMsAAADLAAAAywAAAMsAAADLAAAAywAAAMsAAADLAAAAywAAAMsAAADLAAAAywAAAMsAAADMAAAAzAAAAMwAAADNAAAAzQAAAM0AAADNAAAAzQAAAM0AAADSAAAA0gAAANIAAADSAAAA0gAAANIAAADSAAAA0gAAANIAAADSAAAA0gAAANIAAADTAAAA0wAAANMAAADUAAAA1AAAANQAAADUAAAA1AAAANcAAADXAAAA1wAAANcAAADXAAAA1wAAANcAAADYAAAA2AAAANgAAADZAAAA2QAAANkAAADZAAAA2QAAANwAAADcAAAA3AAAANwAAADcAAAA3AAAANwAAADcAAAA3AAAANwAAADcAAAA3AAAANwAAADcAAAA3AAAANwAAADcAAAA3AAAANwAAADcAAAA3QAAAN0AAADdAAAA3QAAAN0AAADdAAAA3QAAAN0AAADdAAAA3QAAAN0AAADdAAAA3QAAAN0AAADdAAAA3gAAAN4AAADeAAAA3gAAAN4AAADgAAAA4AAAAOAAAADgAAAA4AAAAOAAAADgAAAA4QAAAOEAAADhAAAA4QAAAOEAAADiAAAA4gAAAOIAAADiAAAA4gAAAOIAAADiAAAA4gAAAOMAAADjAAAA4wAAAOMAAADjAAAA4wAAAOMAAADjAAAA4wAAAOMAAADjAAAA5AAAAOQAAADkAAAA5AAAAOQAAADkAAAA5AAAAOQAAADkAAAA5AAAAOQAAADkAAAA5AAAAOUAAADlAAAA5QAAAOUAAADlAAAA5QAAAOcAAADnAAAA5wAAAOcAAADnAAAA5wAAAOcAAADnAAAA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"), "bt", nil, _ENV)()
--
