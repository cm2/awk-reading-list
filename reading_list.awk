#! /usr/bin/awk -f

# reading_list.awk
# 
# generate a reading list from the goodreads library export file
# include a list of currently reading books
# read books will be grouped reverse chronologically 

BEGIN {
	# use pattern to detect csv fields 
	FPAT="([^,]*)|(\"[^\"]+\")";
}


# use to get the field numbers
# change to NR 1 if you want to see the reference
# change to NR 0 if you dont want to see the reference
NR==1 {
	print "REFERENCE"
	for (i=1; i<=NF; i++)
		print i "\t " $i;
	print ""
}

# PART 1: get the books I've read grouped by year
NR==2, NR==max {
	# READ BOOKS
	# if there's a date read, add the book to the list for the year
	date_read = $15
	bookshelves = $17

	if (date_read) {
		# use the date read for collecting the book (unreliable since
		# we only have one read date in the file) since the csv only
		# has one date read derive the years read by the actual date
		# read and lists by year
		# NOTE: does not account for multiple reads in one year

		# add the date read
		year = substr(date_read,1,4)
		years[year] = year

		# add the date read from bookshelves
		split(bookshelves, list_shelves, ",")
		for (i in list_shelves) {
			shelf = list_shelves[i] 
			gsub(/[" ]/,"", shelf)
			if (shelf ~ /^(19|20)[0-9]{2}$/) {
				years[shelf] = shelf
			}
		}


		for (year in years) {
			title = $2
			author = $3
			gsub(/"/,"", title)
			read[year][$1] = title " - " author
		}
		delete years

	}
	# CURRENTLY READING BOOKS
	# get the list of books that are marked as reading
	if ($19 == "currently-reading") {
		title = $2
		author = $3
		gsub(/"/,"", title)
		reading[NR] = title " - " author
	}
}

# PART 2: display the reading list
END {
	line_prefix = "\t - "
	# print the list of books I'm currently reading
	print "Currently Reading"
	for (book in reading)
		print line_prefix reading[book]

	
	# print the list of books I've read in reverse chronological order
	n = asorti(read, sorted)
	for (; n > 0; n--) {
		year = sorted[n]
		numread = length(read[year])
		print year " readling list (" numread  ")"
		for (book in read[year]) {
			print line_prefix read[year][book]
		}
	}
}
