import { useState, useEffect } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { CssBaseline, ThemeProvider, IconButton, Box, Tooltip } from '@mui/material';
import { Brightness4, Brightness7 } from '@mui/icons-material';
import { useTranslation } from 'react-i18next';
import { TodoPage } from './pages/TodoPage';
import { lightTheme, darkTheme } from './theme';
import { LanguageSelector } from './components/LanguageSelector';
import './i18n/i18n'; // i18n 초기화

const queryClient = new QueryClient();

function App() {
  const { t } = useTranslation();
  const [isDarkMode, setIsDarkMode] = useState(() => {
    const saved = localStorage.getItem('darkMode');
    return saved ? JSON.parse(saved) : false;
  });

  useEffect(() => {
    localStorage.setItem('darkMode', JSON.stringify(isDarkMode));
  }, [isDarkMode]);

  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={isDarkMode ? darkTheme : lightTheme}>
        <CssBaseline />
        <Box sx={{ position: 'fixed', top: 16, right: 16, display: 'flex', gap: 1 }}>
          <LanguageSelector />
          <Tooltip title={isDarkMode ? t('app.lightMode') : t('app.darkMode')}>
            <IconButton onClick={() => setIsDarkMode(!isDarkMode)} color="inherit">
              {isDarkMode ? <Brightness7 /> : <Brightness4 />}
            </IconButton>
          </Tooltip>
        </Box>
        <TodoPage />
      </ThemeProvider>
    </QueryClientProvider>
  );
}

export default App;
