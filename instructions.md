# General instructions
1. This is a Flutter app. Most of the functionality is meant to work on Android. If there is any functionality that can work on Linux and/or other operating systems, used the appropriate if conditions to make such functionality available depending on which operating system the app is running on. 
2. The app needs to run in a dark theme by default.
3. Remove syncfusion_flutter_pdfviewer and syncfusion_flutter_pdf from the current project and replace them with pdfrx. Ensure that all functionality of pdfrx is available while viewing the pdf. In a Settings page allow the user to switch between using easy_pdf_viewer or pdfrx. For each package, consider the various functionalities it offers and make those functionalities available for the user in the main screen's overflow menu, depending on the operating system and which package is chosen in Settings.
4. If the app is already open and a new PDF is opened, display tabs which show each new PDF in a separate tab. This is a low priority functionality. 
5. The objective is to have a safe way of viewing PDF files. So the PDF files are stored in the app database and only then opened. So that the PDF has no way of accessing the filesystem. The app also restricts the ability of any script in the PDF to access the internet. This is a high priority feature.
6. The app should manage memory efficiently. If a PDF is too large compared to the amount of available memory, the app should load and unload pages from memory depending on which page the user is currently viewing. If the user suddenly scrolls and there is no time to load pages, the page numbers can be shown in the middle of the screen as the pages scroll by, and when the user stops scrolling, the actual page content can be loaded and shown. If the user is at a certain page, consider pre-loading the next page if there is sufficient memory.
7. For the highlights and themes, use blue shades.
8. Ensure that the database files and lock files are created in a `simple_pdf_files` folder in Linux so that it does not conflict with other files and folders.
9. For any files in the database, provide an option to run another scan for malware on it.
10. In Linux, the user should be allowed to use the arrow keys and pg up and pg dn keys to scroll up or down while viewing the PDF. Also provide all the usual shortcuts like Ctrl+mouseScroll to zoom in or out.

# Main page
* Provide a nav bar at the top of the page. 
* At the left of the Nav bar is a hamburger menu that has options for a Settings page, a Help page, a Trash page, and an About page.
* At the right of the Nav bar is an overflow menu. 
* The nav bar has an icon button to "Load" which opens a modal that allows browsing for a PDF file from the device (a list of recently used folders are shown along with a Browse button to search the filesystem). The modal also provides a URL for downloading a PDF file from the internet and another option for opening a PDF file from a list of PDF files in the app's database.
* The overflow menu has an option to move a PDF file from the app's database to Trash.
* The overflow menu should have an option to save a loaded PDF to storage.
* Ensure that the overflow menu has a way for the user to switch the white PDF background to a darker color (Hint: See if using `ColorFiltered(colorFilter: ColorFilter.mode(Colors.white, darkMode ? BlendMode.difference : BlendMode.dst), child: PdfViewer.file(filePath, ...),),` will help.
* When the PDF is loading, use the `loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {return Center(child: CircularProgressIndicator(value: totalBytes != null ? bytesDownloaded / totalBytes : null, backgroundColor: Colors.grey,),);}` to display a loading banner where possible.
* The overflow menu should have a search option to search for text and highlight it in the pdf and to find next and prev. Consider adding more search features that may be useful.
* The overflow menu should have an option to extract text or images from the PDF and save it to disk as a txt file or png file or svg file, depending on what kind of content it is.
* Easy zooming should be available. 
* Provide an option to set bookmarks, name the bookmarks and edit/delete the names and to be able to jump to bookmarks. The bookmarks can be stored in the database for PDF files that are in the database. 
* Before opening any PDF, the app should perform an offline scan of the PDF for common malware or scripts that it may contain. The user should be shown a modal displaying the progress of the scan, and at the end of the scan the user should be shown a coloured categorized list of threats detected, the specifics of what the threat is in the PDF, and a simple explanation of how such a threat could be harmful and whether the PDF can be opened safely despite the threat being present, and what the user could do to open the PDF safely. (If possible, offer to open the PDF in a safe mode that prevents the PDF from having access to the internet and prevents it from having access to the filesystem or memory). This is a high priority feature.
* Provide an option to allow the user to jump to a specific page of the PDF.
* Provide an option to view the PDF in fullscreen mode and to be able to switch back.
* Provide an option to open a modal containing checkboxes for each of the PDF pages, thumbnails of each page and allowing the user to select one or more pages (along with options of "Select all/none"). The user should be allowed to merge the selected pages and save it as a new PDF in the database (give it a default name based on the earlier name plus the date and time of merging).
* An option to store the files in encrypted form in the database and to be able to export or import encrypted PDF's of this app.
* An option to rename the PDF files stored in the database.

# Text to speech
1. use flutter_tts for reading out text, and provide all the controls that flutter_tts allows. Keep the architecture flexible in case the programmer wants to add more text to speech engines later.

# Settings
* Provide a plausible deniability toggle which when switched on will ask the user to type a real password and a fake password. The passwords are hashed and salted and stored in the database. After the user closes the app and opens it, the user will be asked for the password. If the user types the correct password, the user is allowed access to the usual pdf files. If the user types the fake password, the user is not shown the usual pdf files stored in the database and is not shown the recent files or folders. If the user types the fake password, the user is shown a totally different view where the user can load and view a different set of pdf files and can even store pdf files in a separate database, and those files and folders will be shown only if the user types the fake password. 
* If the user types the fake password, the Settings page will not contain the plausible deniability toggle. The plausible deniability toggle is only available if the toggle is switched off or if the user types the real password.
* Depending on which operating systems the flutter packages work on, provide a dropdown that allows the user to choose whether pdfrx or easy_pdf_viewer is used for viewing or editing PDF files. 
* Provide an option to change the theme from dark to light or system theme. Dark theme is the default.
* Provide a dropdown for the user to choose various parameters available in flutter_tts.
* Provide an option to customize the scroll and zoom physics.
* Provide an option to view and delete the bookmarks of any file.
* Provide an option to toggle whether the app scans the PDF for malware before opening or does not perform the scan.
* Provide an option to make the app load the entire PDF or just load only the page that needs to be shown, to save on memory.
* Provide an option to adjust the scroll speed.

# Trash page
* Provide a nav bar with options for select all, select none (if any are selected), delete permanently and restore. 
* Each deleted option should be shown with a checkbox on the left side.

# Help page
* Explain the functionality of the app. 
* Provide an FAQ.

# About page
* Display the app version number and name of the app creator as "Nav".
