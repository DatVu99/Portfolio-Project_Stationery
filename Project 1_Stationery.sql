/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) *
  FROM [Stationery_Project].[dbo].[pen_business$]


  -- EDA
		Select count([Mã sản phẩm])
		From Stationery_Project..pen_business$

		-- Total rows: 65.535
		-- Explore column

	-- Kỳ
		Select distinct(kỳ)
		From Stationery_Project..pen_business$
		order by kỳ
		--> Found un-consistant values (1.202, 52019, 12.202, 112019,...)
		--> Re-check with orginal database on kaggle: https://www.kaggle.com/datasets/nhatlinhtran/pens-business-in-viet-nam-2020?select=pen_business.csv
		--> Expected format: 1.2020, 5.2019, 12.2020, 11.2019,...
		--> Correct outliners 

		Select distinct(kỳ), str(kỳ) as string,
					case 
					when str(kỳ) < 10 and len(kỳ) < 6 then concat(kỳ,0)
					when str(kỳ) between 10 and 13 and len(kỳ) <7 then concat(kỳ,0)
					when str(kỳ) > 13 and len(kỳ) <= 5 then concat(left(kỳ,1),'.',RIGHT(kỳ,4)) 
					when str(kỳ) > 13 and len(kỳ) > 5 then concat(left(kỳ,2),'.',RIGHT(kỳ,4))
					else kỳ
					end
		From Stationery_Project..pen_business$
		order by str(kỳ)


		Alter table Stationery_Project..Pen_business$
		alter column kỳ nvarchar(255)


		Update Stationery_Project..pen_business$
		Set Kỳ = case 
					when str(kỳ) < 10 and len(kỳ) < 6 then concat(kỳ,0)
					when str(kỳ) between 10 and 13 and len(kỳ) <7 then concat(kỳ,0)
					when str(kỳ) > 13 and len(kỳ) <= 5 then concat(left(kỳ,1),'.',RIGHT(kỳ,4)) 
					when str(kỳ) > 13 and len(kỳ) > 5 then concat(left(kỳ,2),'.',RIGHT(kỳ,4))
					else kỳ
					end

				
	-- Sepertate the month & year for visualize purposes
			Alter table Stationery_Project..pen_business$
			add Tháng float, Năm float

		-- Insert month
			Update Stationery_Project..Pen_business$
			set Tháng = case 
					when SUBSTRING(kỳ,1,2) like '%.%' then LEFT(kỳ,1)
					else left(kỳ,2)
					end
			From Stationery_Project..pen_business$

		-- Insert year
			Update Stationery_Project..Pen_business$
			set Năm = right(kỳ,4) 
				
		-- Re-check
			Select distinct(Tháng)
			From Stationery_Project..Pen_business$
			order by Tháng

			Select distinct(Năm)
			from Stationery_Project..Pen_business$
			Order by Năm


	-- Mã sản phẩm & tên sản phẩm
	-- Check duplicate items

		Select [Mã sản phẩm], [Tên sản phẩm], ROW_NUMBER() over (partition by [mã sản phẩm] order by [tên sản phẩm])
		From Stationery_Project..pen_business$
		group by [Mã sản phẩm], [Tên sản phẩm]
		-- No duplicate

	-- Nhóm Sp-cấp 1 and Tên Nhóm Sp - Cấp 1
		Select distinct([Nhóm SP - Cấp 1]), [Tên Nhóm SP - Cấp 1]
		From Stationery_Project..pen_business$
		-- Found "Null value"

		Select top 1000 * 
		From Stationery_Project..pen_business$
		where [Nhóm SP - Cấp 1] is null
		-- Null value is the "50000819 - Bút lông kim Fl04 đen-hộp 10 cây"

		Select *
		From Stationery_Project..pen_business$
		Where [Mã sản phẩm] = 50000819

		-- Re-check & confirm with stakeholder whether it's Nhóm Sp-câp 1 = 1 & Tên nhóm Sp-Cấp 1 = "Nhóm Bút Viết"
		-- Correct

		Update Stationery_Project..pen_business$
		Set [Nhóm SP - Cấp 1] = 1
			, [Tên Nhóm SP - Cấp 1] = N'NHÓM BÚT VIẾT'
		Where [Mã sản phẩm] = 50000819 


	-- Nhóm Sp-cấp 2 and Tên Nhóm Sp - Cấp 2
		Select distinct([Nhóm SP - Cấp 2]), [Tên Nhóm SP - Cấp 2]
		From Stationery_Project..pen_business$
		order by [Nhóm SP - Cấp 2]
		-- No duplicate 

		Select *
		From Stationery_Project..pen_business$
		where Kỳ is null
			or [Mã sản phẩm] is null
			or [Tên sản phẩm] is null
			or [Nhóm SP - Cấp 1] is null
			or [Tên Nhóm SP - Cấp 1] is null
			or [Nhóm SP - Cấp 2] is null
			or [Tên Nhóm SP - Cấp 2] is null
			or [Nhóm SP - Cấp 3] is null
			or [Tên Nhóm SP - Cấp 3] is null
			or [Nhóm SP - Cấp 4] is null
			or [Tên Nhóm SP - Cấp 4] is null
			or [Kênh phân phối] is null
			or [Tên Kênh phân phối] is null
			or [ Số lượng ] is null
			or [ Doanh thu ] is null
			or [ Giá vốn ] is null
			or [ Chi phí ] is null
		-- Found "Null value" in column "Tên nhóm SP - cấp 3": 50000521, 50000526, 50000528, 50000531
		-- Found "Null value" in column "Tên nhóm SP - cấp 4": 50000921, 50000094
		-- Found "Null value" in column "Tên Kênh phân phối"
		-- Found "Null value" in column "Số lượng"
		-- Found "Null value" in column "Doanh Thu" & "Giá vốn" & "Chí Phí" (same row "50000518")


	-- Tên nhóm SP - cấp 3: Check the correct name
			Select *
			From Stationery_Project..pen_business$
			where [Mã sản phẩm] = 50000521
			order by [Tên Nhóm SP - Cấp 3]
			--> Bút bi

			Select *
			From Stationery_Project..pen_business$
			where [Mã sản phẩm] = 50000526
			order by [Tên Nhóm SP - Cấp 3]
			--> Bút Gel

			Select *
			From Stationery_Project..pen_business$
			where [Mã sản phẩm] = 50000528
			order by [Tên Nhóm SP - Cấp 3]	
			--> Bút Gel

			Select *
			From Stationery_Project..pen_business$
			where [Mã sản phẩm] = 50000531
			order by [Tên Nhóm SP - Cấp 3]	
			--> Bút Gel

			Update Stationery_Project..pen_business$
			set [Tên Nhóm SP - Cấp 3] = case 
				when [Mã sản phẩm] = 50000521 then  N'BÚT BI'
				When [Mã sản phẩm] = 50000526 then  N'BÚT GEL'
				when [Mã sản phẩm] = 50000528 then  N'BÚT GEL'
				when [Mã sản phẩm] = 50000531 then  N'BÚT GEL'
				else [Tên Nhóm SP - Cấp 3]
				end


	-- Tên nhóm SP - cấp 4: 50000921, 50000094
			Select *
			From Stationery_Project..pen_business$
			where [Mã sản phẩm] = 50000921
			order by [Tên Nhóm SP - Cấp 4]
			--> Bút HL03

			Select *
			From Stationery_Project..pen_business$
			where [Mã sản phẩm] = 50000094
			order by [Tên Nhóm SP - Cấp 4]	
			--> Bút TL031

			Update Stationery_Project..pen_business$
			set [Tên Nhóm SP - Cấp 4] = case 
				when [Mã sản phẩm] = 50000921 then  N'Bút HL03'
				When [Mã sản phẩm] = 50000094 then  N'Bút TL031'
				else [Tên Nhóm SP - Cấp 4]
				end

	-- Tên Kênh phân phối
			Select distinct([Tên Kênh phân phối]), [Kênh phân phối]
			From Stationery_Project..pen_business$
			-- Found Kênh phân phối = 10 has three name: Mordern Trade, Null & General Trade
			-- Confirmed with Stakeholder: Mordern Trade = 20, General Trade = 10

			Update Stationery_Project..pen_business$
			Set [Kênh phân phối] = case 
				when [Tên Kênh phân phối] like 'Mo%' then 20
				when [Tên Kênh phân phối] = 'General Trade' then 10
				end
	
			Delete from Stationery_Project..pen_business$
			where [Kênh phân phối] is null 

	-- Remove Null in Số lượng
			Delete from Stationery_Project..pen_business$
			where [ Số lượng ] is null or [ Chi phí ] is null
			
-- Adding columns: Lợi nhuận (Profit)
		Alter table Stationery_Project..pen_business$
		add [Lợi nhuận] float

		Update Stationery_Project..Pen_business$
		Set [Lợi nhuận] = ([ Doanh thu ] - [ Giá vốn ] - [ Chi phí ])


-- Find duplicate value
		Select Kỳ, [Mã sản phẩm], [ Số lượng ], [ Doanh thu ], [ Giá vốn ], [ Chi phí ], [Nhóm SP - Cấp 4],[Kênh phân phối],[Vùng bán hàng ], count(*) as Number_of_duplicate
		From Stationery_Project..Pen_business$
		Group by Kỳ, [Mã sản phẩm], [ Số lượng ], [ Doanh thu ], [ Giá vốn ], [ Chi phí ], [Nhóm SP - Cấp 4],[Kênh phân phối],[Vùng bán hàng ]
		Having count(*) > 1

		
		Alter table Stationery_Project..Pen_business$
		add Temp_column int IDENTITY (1,1);


		--> Found 14 duplicate values
		--> Remove them by create a temporate column 

		Delete from Stationery_Project..Pen_business$
		Where temp_column in (
			Select max(temp_column)
			From Stationery_Project..Pen_business$
			Group by Kỳ, [Mã sản phẩm], [ Số lượng ], [ Doanh thu ], [ Giá vốn ], [ Chi phí ], [Nhóm SP - Cấp 4],[Kênh phân phối],[Vùng bán hàng ]
			Having count(*) > 1)
			
		Alter table Stationery_Project..Pen_business$
		Drop column temp_column