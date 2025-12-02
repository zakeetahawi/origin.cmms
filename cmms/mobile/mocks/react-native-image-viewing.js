// Mock for react-native-image-viewing on web
import React from 'react';

export default function ImageViewing({ images, imageIndex, visible, onRequestClose, ...props }) {
    if (!visible) return null;

    return React.createElement('div', {
        style: {
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'black',
            zIndex: 9999,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
        },
        onClick: onRequestClose,
    }, [
        images && images[imageIndex] && React.createElement('img', {
            key: 'image',
            src: images[imageIndex].uri,
            style: { maxWidth: '90%', maxHeight: '90%' },
            alt: 'Viewing',
        }),
        React.createElement('button', {
            key: 'close',
            onClick: onRequestClose,
            style: {
                position: 'absolute',
                top: 20,
                right: 20,
                background: 'white',
                border: 'none',
                padding: '10px 20px',
                cursor: 'pointer',
                borderRadius: 5,
            },
        }, 'Close'),
    ]);
}
