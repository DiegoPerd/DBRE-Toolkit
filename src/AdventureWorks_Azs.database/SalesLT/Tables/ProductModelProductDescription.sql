CREATE TABLE [SalesLT].[ProductModelProductDescription] (
    [ProductModelID]       INT              NOT NULL,
    [ProductDescriptionID] INT              NOT NULL,
    [Culture]              NCHAR (6)        NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL,
    [ModifiedDate]         DATETIME         NOT NULL
);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary key. Foreign key to ProductModel.ProductModelID.', @level0type = N'SCHEMA', @level0name = N'SalesLT', @level1type = N'TABLE', @level1name = N'ProductModelProductDescription', @level2type = N'COLUMN', @level2name = N'ProductModelID';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary key. Foreign key to ProductDescription.ProductDescriptionID.', @level0type = N'SCHEMA', @level0name = N'SalesLT', @level1type = N'TABLE', @level1name = N'ProductModelProductDescription', @level2type = N'COLUMN', @level2name = N'ProductDescriptionID';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The culture for which the description is written', @level0type = N'SCHEMA', @level0name = N'SalesLT', @level1type = N'TABLE', @level1name = N'ProductModelProductDescription', @level2type = N'COLUMN', @level2name = N'Culture';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time the record was last updated.', @level0type = N'SCHEMA', @level0name = N'SalesLT', @level1type = N'TABLE', @level1name = N'ProductModelProductDescription', @level2type = N'COLUMN', @level2name = N'ModifiedDate';
GO

ALTER TABLE [SalesLT].[ProductModelProductDescription]
    ADD CONSTRAINT [FK_ProductModelProductDescription_ProductDescription_ProductDescriptionID] FOREIGN KEY ([ProductDescriptionID]) REFERENCES [SalesLT].[ProductDescription] ([ProductDescriptionID]);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key constraint referencing ProductDescription.ProductDescriptionID.', @level0type = N'SCHEMA', @level0name = N'SalesLT', @level1type = N'TABLE', @level1name = N'ProductModelProductDescription', @level2type = N'CONSTRAINT', @level2name = N'FK_ProductModelProductDescription_ProductDescription_ProductDescriptionID';
GO

ALTER TABLE [SalesLT].[ProductModelProductDescription]
    ADD CONSTRAINT [FK_ProductModelProductDescription_ProductModel_ProductModelID] FOREIGN KEY ([ProductModelID]) REFERENCES [SalesLT].[ProductModel] ([ProductModelID]);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key constraint referencing ProductModel.ProductModelID.', @level0type = N'SCHEMA', @level0name = N'SalesLT', @level1type = N'TABLE', @level1name = N'ProductModelProductDescription', @level2type = N'CONSTRAINT', @level2name = N'FK_ProductModelProductDescription_ProductModel_ProductModelID';
GO

ALTER TABLE [SalesLT].[ProductModelProductDescription]
    ADD CONSTRAINT [DF_ProductModelProductDescription_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Default constraint value of GETDATE()', @level0type = N'SCHEMA', @level0name = N'SalesLT', @level1type = N'TABLE', @level1name = N'ProductModelProductDescription', @level2type = N'CONSTRAINT', @level2name = N'DF_ProductModelProductDescription_ModifiedDate';
GO

ALTER TABLE [SalesLT].[ProductModelProductDescription]
    ADD CONSTRAINT [DF_ProductModelProductDescription_rowguid] DEFAULT (newid()) FOR [rowguid];
GO

ALTER TABLE [SalesLT].[ProductModelProductDescription]
    ADD CONSTRAINT [AK_ProductModelProductDescription_rowguid] UNIQUE NONCLUSTERED ([rowguid] ASC);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique nonclustered constraint. Used to support replication samples.', @level0type = N'SCHEMA', @level0name = N'SalesLT', @level1type = N'TABLE', @level1name = N'ProductModelProductDescription', @level2type = N'CONSTRAINT', @level2name = N'AK_ProductModelProductDescription_rowguid';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cross-reference table mapping product descriptions and the language the description is written in.', @level0type = N'SCHEMA', @level0name = N'SalesLT', @level1type = N'TABLE', @level1name = N'ProductModelProductDescription';
GO

ALTER TABLE [SalesLT].[ProductModelProductDescription]
    ADD CONSTRAINT [PK_ProductModelProductDescription_ProductModelID_ProductDescriptionID_Culture] PRIMARY KEY CLUSTERED ([ProductModelID] ASC, [ProductDescriptionID] ASC, [Culture] ASC);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary key (clustered) constraint', @level0type = N'SCHEMA', @level0name = N'SalesLT', @level1type = N'TABLE', @level1name = N'ProductModelProductDescription', @level2type = N'CONSTRAINT', @level2name = N'PK_ProductModelProductDescription_ProductModelID_ProductDescriptionID_Culture';
GO

