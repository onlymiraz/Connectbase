This script downloads all Frontier Wholesale contracts
to a local directory ("C:/Docusign_Contracts").
It should recursively gather all files and folders, with resilience to errors.
It takes several hours to run, possibly even over a day.
This is because it slowly loops through thousands of files.

You must have DocuSign admin. Any password works; only private key needed.
IT provided 4 kinds of admin before it finally worked.
Not known which combination is truly needed.
To get access, contact:

* Rahman, Mithu - Director approval
* Karim, Rezaul - Gives admins
* Zaman, Monir - Helps troubleshoot

Hints:

* There is more than one admin; don't trust being told it's done bc you may not have been given the correct type.
* Some things can be inferred from the code. For example, hostname = 'sftpna11.springcm.com'. Tutorials saying different are wrong.
* For generating public/private keys, you cannot use puttygen and do it yourself. It must be done from a specific DocuSign page.


There are several contradictory tutorials.
Some combination of them will end up working.

https://support.docusign.com/s/document-item?language=en_US&bundleId=hkd1606923970531&topicId=itm1606923970266.html&_LANG=enus

https://support.docusign.com/s/document-item?language=en_US&bundleId=pxt1643324456371&topicId=fgy1619203740592.html&_LANG=enus

https://support.docusign.com/s/document-item?language=en_US&bundleId=pxt1643324456371&topicId=yva1619203531519.html&_LANG=enus

One final note: this is only the contract files. For other info,
such as attribute key-values, someone needs to run a report
and provide. Only then will you truly be ready to perform RAG.