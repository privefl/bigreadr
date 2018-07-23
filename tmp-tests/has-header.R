part1 <- fread2(file_parts[1], skip = skip, ...)
first_line <- scan(file, "", skip = skip, nlines = 1, sep = "\n", quiet = TRUE)
match_names <- sapply(names(part1), regexpr, text = first_line, fixed = TRUE)
has_header <- all( diff(match_names) > 0 )
