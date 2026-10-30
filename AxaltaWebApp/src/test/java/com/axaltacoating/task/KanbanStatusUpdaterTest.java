package com.axaltacoating.task;

import com.axaltacoating.model.Inventory;
import com.axaltacoating.util.DatabaseConnection;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import static org.mockito.Mockito.*;

public class KanbanStatusUpdaterTest {

    @Mock
    private Connection mockConnection;
    @Mock
    private PreparedStatement mockStatement;
    @Mock
    private ResultSet mockResultSet;

    private KanbanStatusUpdater updater;

    @Before
    public void setUp() throws SQLException {
        MockitoAnnotations.openMocks(this);
        updater = new KanbanStatusUpdater();

        // Mock DatabaseConnection to return our mock Connection
        when(DatabaseConnection.getConnection()).thenReturn(mockConnection);

        when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
        when(mockStatement.executeQuery()).thenReturn(mockResultSet);
    }

    @Test
    public void testUpdateKanbanStatuses() throws SQLException {
        // Mock ResultSet to return test data
        when(mockResultSet.next()).thenReturn(true, true, false);
        when(mockResultSet.getInt("id")).thenReturn(1, 2);
        when(mockResultSet.getInt("quantity")).thenReturn(5, 15);
        when(mockResultSet.getInt("min_threshold")).thenReturn(10, 10);
        when(mockResultSet.getInt("max_threshold")).thenReturn(20, 20);

        // Run the update method
        updater.run();

        // Verify that the correct SQL queries were executed
        verify(mockConnection, times(1)).prepareStatement("SELECT id, quantity, min_threshold, max_threshold FROM inventory");
        verify(mockConnection, times(2)).prepareStatement("UPDATE inventory SET kanban_status = ? WHERE id = ?");

        // Verify that the correct Kanban statuses were set
        verify(mockStatement).setString(1, "Low");
        verify(mockStatement).setInt(2, 1);
        verify(mockStatement).setString(1, "Medium");
        verify(mockStatement).setInt(2, 2);
    }

    @Test
    public void testHandleSQLException() throws SQLException {
        // Simulate a SQLException when executing the query
        when(mockStatement.executeQuery()).thenThrow(new SQLException("Test exception"));

        // Run the update method
        updater.run();

        // Verify that the method handled the exception gracefully
        verify(mockConnection, times(1)).prepareStatement("SELECT id, quantity, min_threshold, max_threshold FROM inventory");
        verify(mockConnection, never()).prepareStatement("UPDATE inventory SET kanban_status = ? WHERE id = ?");
    }
}