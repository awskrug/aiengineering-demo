import { useTranslation } from 'react-i18next';
import { List, Typography, Box } from '@mui/material';
import { Todo } from '../types/todo';
import { TodoItem } from './TodoItem';

interface TodoListProps {
  todos: Todo[];
  onToggle: (id: string, completed: boolean) => void;
  onEdit: (todo: Todo) => void;
  onDelete: (id: string) => void;
}

export function TodoList({ todos, onToggle, onEdit, onDelete }: TodoListProps) {
  const { t } = useTranslation();

  if (todos.length === 0) {
    return (
      <Box sx={{ textAlign: 'center', py: 4 }}>
        <Typography variant="body1" color="text.secondary">
          {t('todo.empty')}
        </Typography>
      </Box>
    );
  }

  return (
    <List sx={{ width: '100%', bgcolor: 'background.paper' }}>
      {todos.map((todo) => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onToggle={onToggle}
          onEdit={onEdit}
          onDelete={onDelete}
        />
      ))}
    </List>
  );
}
