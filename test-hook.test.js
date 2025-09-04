describe('testFunction', () => {
  it('should add two numbers correctly', () => {
    expect(testFunction(2, 3)).toBe(5);
  });
  
  it('should handle zero values', () => {
    expect(testFunction(0, 0)).toBe(0);
  });
});