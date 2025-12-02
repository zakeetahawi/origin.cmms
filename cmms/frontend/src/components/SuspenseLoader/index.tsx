import { useEffect } from 'react';
import NProgress from 'nprogress';
import { Box } from '@mui/material';

function SuspenseLoader() {
  useEffect(() => {
    NProgress.start();

    return () => {
      NProgress.done();
    };
  }, []);

  return (
    <Box
      sx={{
        position: 'fixed',
        left: 0,
        top: 0,
        width: '100%',
        height: '100%',
        backgroundColor: 'background.paper'
      }}
      display="flex"
      alignItems="center"
      justifyContent="center"
    >
      <Box
        component="img"
        src="/static/images/logo/company-logo.png"
        alt="Loading..."
        sx={{
          width: 120,
          height: 120,
          animation: 'pulse 1.5s ease-in-out infinite',
          '@keyframes pulse': {
            '0%': { opacity: 1, transform: 'scale(1)' },
            '50%': { opacity: 0.6, transform: 'scale(0.95)' },
            '100%': { opacity: 1, transform: 'scale(1)' }
          }
        }}
      />
    </Box>
  );
}

export default SuspenseLoader;
