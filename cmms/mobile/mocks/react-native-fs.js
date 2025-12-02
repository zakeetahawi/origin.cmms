// Mock for react-native-fs on web
const RNFS = {
    RNFSFileTypeRegular: 0,
    RNFSFileTypeDirectory: 1,
    DocumentDirectoryPath: '',
    CachesDirectoryPath: '',
    ExternalDirectoryPath: '',
    ExternalStorageDirectoryPath: '',
    TemporaryDirectoryPath: '',
    LibraryDirectoryPath: '',
    PicturesDirectoryPath: '',
    DownloadDirectoryPath: '/downloads',

    writeFile: () => Promise.resolve(),
    readFile: () => Promise.resolve(''),
    readdir: () => Promise.resolve([]),
    stat: () => Promise.resolve({}),
    exists: () => Promise.resolve(false),
    unlink: () => Promise.resolve(),
    mkdir: () => Promise.resolve(),
    downloadFile: (options) => ({
        jobId: -1,
        promise: Promise.resolve({ jobId: -1, statusCode: 200, bytesWritten: 100 })
    }),
    uploadFiles: () => ({ promise: Promise.resolve() }),
    pathForBundle: () => '',
};

export default RNFS;

// Named exports
export const {
    RNFSFileTypeRegular,
    RNFSFileTypeDirectory,
    DocumentDirectoryPath,
    CachesDirectoryPath,
    ExternalDirectoryPath,
    ExternalStorageDirectoryPath,
    TemporaryDirectoryPath,
    LibraryDirectoryPath,
    PicturesDirectoryPath,
    DownloadDirectoryPath,
    writeFile,
    readFile,
    readdir,
    stat,
    exists,
    unlink,
    mkdir,
    downloadFile,
    uploadFiles,
    pathForBundle
} = RNFS;
