ConvertFrom-StringData @'
 ParameterStringEmpty=The parameter '{0}' can not be an empty string.
 PathMustExist=The path does not exist : {0}
 PathIsNotAFile=The path does not reference to a file or the path is invalid : {0}  
 ValueNotSupported=The value '{0}' is not supported by PSIonic.
 TypeNotSupported={0}: The type '{1}' is not supported.
 CommentMaxValue=The value of 'Comment' parameter must not exceeds 32767 characters.

 isBadPasswordWarning=Bad password for the archive {0}
 ZipArchiveBadPassword=An invalid password was given to extract archive {0}.
 InvalidPasswordForDataEncryptionValue=The value provided for Password parameter ('{0}') is invalid for the given value of DataEncryption '{1}'.
 ZipArchiveCheckPasswordError=Error occured while checking password on the archive {0} : {1}.

 AddEntryError=Can not add the entry '{0}' into the archive '{1}': {2}
 EntryIsNull=The entry '{0}' is `$null.
 ExpandZipEntryError=The entry named '{0}' do not exist in the archive '{1}'
 
 RemoveEntryError=Impossible to delete the entry  '{0}' into archive '{1}', because it does not exist.
 RemoveEntryNullError=The argument is null.Archive concerned '{0}'
 
 ZipArchiveReadError=Error occured while reading the archive {0} : {1}.
 ZipArchiveExtractError=Error occured while extracting the archive {0} : {1}.
 ZipArchiveCheckIntegrityError=Error occured while checking the archive integrity {0} : {1}.
 isCorruptedZipArchiveWarning=Corrupted archive : {0}

 TestisArchiveError=Error occured while testing the archive {0} : {1}.
 isNotZipArchiveWarning=The file is not a zip archive : {0}
 
 ExcludedObject=The current object is not an instance of System.IO.FileInfo type : {0}
 IsNullOrEmptyArchivePath=The file name is empty or ToString() return an empty string.
 ItemNotFound=Can not find the path '{0}', because it does not exist.
 EmptyResolve=The resolve does not find file.
 PathNotInEntryPathRoot=The path is not in the root directory : {0}
 UnableToConvertEntryRootPath=Unable to convert the root path : {0}
 FromPathEntryNotFound=Can not find the path '{0}' in the archive '{1}', because it does not exist.
 
 ThisParameterRequiresThisParameter=The '{0}' parameter requires to declare the '{1}' parameter. 
 
 ProgressBarExtract=Extract in progress
'@ 

