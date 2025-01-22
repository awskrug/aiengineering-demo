import { useState } from 'react';
import { Button, TextField, Box } from '@mui/material';
import { CreateTodoInput } from '../types/todo';

interface AddTodoFormProps {
  onSubmit: (todo: CreateTodoInput) => void;
}

export function AddTodoForm({ onSubmit }: AddTodoFormProps) {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return;

    onSubmit({
      title: title.trim(),
      description: description.trim() || undefined,
    });

    setTitle('');
    setDescription('');
  };

  return (
    <Box
      component="form"
      onSubmit={handleSubmit}
      sx={{
        display: 'flex',
        flexDirection: 'column',
        gap: 2,
        width: '100%',
        mb: 4,
      }}
    >
      <TextField
        label="할 일"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        required
        fullWidth
      />
      <TextField
        label="설명"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        multiline
        rows={2}
        fullWidth
      />
      <Button type="submit" variant="contained" disabled={!title.trim()}>
        추가
      </Button>
    </Box>
  );
}